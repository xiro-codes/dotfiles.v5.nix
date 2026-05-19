#!/usr/bin/env python3
import os
import sys
import re
import time
import json
import shlex
import subprocess
import threading
import concurrent.futures
from collections import deque

# State variables
RESOLVED_HASHES = {}  # Map hash (32-char store hash or 52-char narhash) -> package name
RAW_LOG_LINES = deque(maxlen=1000)
PARSED_PULLS = deque(maxlen=100)
ACTIVE_BUILDS = {"ruby": [], "sapphire": []}
RUNNING = True
STATE_LOCK = threading.Lock()

# Logging pattern for Harmonia (actix-web logger)
# E.g., '192.168.1.73 "GET /nar/05a6i33z411m2ykhmsfshx1lq99h2q1l1z1b71x4z0k1l21w1g1p.nar.xz HTTP/1.1" 200 4523'
# E.g., '192.168.1.66 "GET /2wn9mr9cvb3sif0kyrl5d025wn90bzxv.narinfo HTTP/1.1" 404 123'
LOG_PATTERN = re.compile(
    r'(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(:\d+)?'  # IP address with optional port
    r'.*?'
    r'"(?P<method>[A-Z]+)\s+(?P<path>/[^\s"]+)\s+[^"]*"'  # "GET /path HTTP/1.1"
    r'\s+(?P<status>\d{3})'                              # HTTP Status
)

# Colors
C_RESET = "\033[0m"
C_BOLD = "\033[1m"
C_DIM = "\033[2m"
C_GRAY = "\033[90m"

C_GREEN = "\033[38;2;166;226;46m"
C_RED = "\033[38;2;249;38;114m"
C_CYAN = "\033[38;2;102;217;239m"
C_YELLOW = "\033[38;2;230;219;116m"
C_PURPLE = "\033[38;2;174;129;255m"

def extract_hash_from_path(path):
    parts = path.strip('/').split('/')
    if not parts:
        return None, None
    if parts[0] == 'nar' and len(parts) > 1:
        # It's a nar file request, hash is the filename up to first dot
        filename = parts[1]
        narhash = filename.split('.')[0]
        return narhash, 'nar'
    elif parts[0].endswith('.narinfo'):
        # It's a narinfo request, hash is the prefix before .narinfo
        hash32 = parts[0].split('.')[0]
        return hash32, 'narinfo'
    return None, None

def resolve_hashes_remote(hashes):
    if not hashes:
        return {}
    
    # Python script to run on Onix
    py_code = f"""
import os, glob, urllib.request, json
hashes = {repr(list(hashes))}
results = {{}}
for h in hashes:
    # 1. Try finding in /nix/store if it is a 32-character hash
    if len(h) == 32:
        paths = glob.glob(f'/nix/store/{{h}}-*')
        if paths:
            results[h] = os.path.basename(paths[0])
            continue
    # 2. Try querying Harmonia for narinfo metadata
    if len(h) == 32:
        try:
            req = urllib.request.Request(f'http://127.0.0.1:5001/{{h}}.narinfo')
            with urllib.request.urlopen(req, timeout=1.0) as res:
                content = res.read().decode('utf-8')
                store_path = None
                nar_url = None
                for line in content.split('\\n'):
                    if line.startswith('StorePath:'):
                        store_path = line.split(': ', 1)[1].strip()
                    elif line.startswith('URL:'):
                        nar_url = line.split(': ', 1)[1].strip()
                if store_path:
                    name = os.path.basename(store_path)
                    results[h] = name
                    if nar_url and nar_url.startswith('nar/'):
                        narhash = nar_url.split('/')[1].split('.')[0]
                        results[narhash] = name
        except Exception:
            pass
print(json.dumps(results))
"""
    cmd = ["ssh", "-o", "ConnectTimeout=2", "-o", "StrictHostKeyChecking=no", "-F", "/dev/null", "root@onix", "python3"]
    try:
        proc = subprocess.run(cmd, input=py_code, capture_output=True, text=True, timeout=4)
        if proc.returncode == 0:
            return json.loads(proc.stdout.strip())
    except Exception:
        pass
    return {}

def hash_resolver_worker():
    global RUNNING
    while RUNNING:
        # Collect any hashes from logs that are not resolved
        unresolved = set()
        with STATE_LOCK:
            for item in PARSED_PULLS:
                h = item.get('hash')
                if h and h not in RESOLVED_HASHES:
                    unresolved.add(h)
        
        if unresolved:
            resolved = resolve_hashes_remote(unresolved)
            if resolved:
                with STATE_LOCK:
                    RESOLVED_HASHES.update(resolved)
                    # For anything we resolved, update our PARSED_PULLS items
                    for item in PARSED_PULLS:
                        h = item.get('hash')
                        if h in RESOLVED_HASHES:
                            item['name'] = RESOLVED_HASHES[h]
        
        time.sleep(1.0)

def parse_log_line(line):
    match = LOG_PATTERN.search(line)
    if match:
        ip = match.group('ip')
        method = match.group('method')
        path = match.group('path')
        status = int(match.group('status'))
        
        # Try to parse timestamp from Nginx format: [dd/MMM/yyyy:HH:MM:SS +zzzz]
        # or fallback to journalctl format: YYYY-MM-DDTHH:MM:SS
        timestamp = ""
        nginx_ts_match = re.search(r'\[\d{2}/\w{3}/\d{4}:(?P<time>\d{2}:\d{2}:\d{2}) [+-]\d{4}\]', line)
        if nginx_ts_match:
            timestamp = nginx_ts_match.group('time')
        else:
            ts_match = re.match(r'^([\d\-T\:\.Z]+)', line)
            if ts_match:
                # Format nicely: HH:MM:SS
                raw_ts = ts_match.group(1)
                # Extract HH:MM:SS
                time_part = raw_ts.split('T')[-1].split('.')[0].rstrip('Z')
                timestamp = time_part
            else:
                timestamp = time.strftime("%H:%M:%S")
            
        h, h_type = extract_hash_from_path(path)
        
        # Build entry
        entry = {
            "timestamp": timestamp,
            "ip": ip,
            "method": method,
            "path": path,
            "status": status,
            "hash": h,
            "type": h_type,
            "name": RESOLVED_HASHES.get(h, h[:10] if h else "unknown")
        }
        return entry
    return None

def onix_log_streamer():
    global RUNNING
    # Stream logs continuously using SSH tail -F on Nginx harmonia access log
    cmd = ["ssh", "-o", "ConnectTimeout=2", "-o", "StrictHostKeyChecking=no", "-F", "/dev/null", "root@onix", "tail -F -n 100 /var/log/nginx/harmonia.access.log"]
    while RUNNING:
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
            for line in proc.stdout:
                if not RUNNING:
                    break
                line = line.strip()
                if line:
                    entry = parse_log_line(line)
                    if entry:
                        with STATE_LOCK:
                            PARSED_PULLS.append(entry)
            proc.terminate()
        except Exception:
            time.sleep(2.0)

def query_builder(host):
    cmd = [
        "ssh", "-o", "ConnectTimeout=2", "-o", "StrictHostKeyChecking=no", "-F", "/dev/null",
        f"root@{host}",
        "find /proc -maxdepth 2 -name cwd -lname '/tmp/nix-build-*' -exec readlink {} \\; 2>/dev/null"
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=3)
        if proc.returncode != 0 and not proc.stdout.strip():
            err = proc.stderr.strip()
            if err:
                return [f"Error ({err[:30]})"]
        
        builds = set()
        for line in proc.stdout.split('\n'):
            line = line.strip()
            if not line:
                continue
            for part in line.split('/'):
                if part.startswith('nix-build-'):
                    name = part[len('nix-build-'):]
                    if '.drv-' in name:
                        name = name.split('.drv-')[0]
                    elif name.endswith('.drv'):
                        name = name[:-4]
                    builds.add(name)
                    break
        return list(builds)
    except subprocess.TimeoutExpired:
        return ["Timeout"]
    except Exception as e:
        return [f"Offline ({str(e)[:30]})"]


def query_builders_loop():
    global RUNNING
    while RUNNING:
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            future_ruby = executor.submit(query_builder, "ruby")
            future_sapphire = executor.submit(query_builder, "sapphire")
            
            ruby_res = future_ruby.result()
            sapphire_res = future_sapphire.result()
            
        with STATE_LOCK:
            ACTIVE_BUILDS["ruby"] = ruby_res
            ACTIVE_BUILDS["sapphire"] = sapphire_res
            
        time.sleep(2.0)

def get_onix_summary():
    # Helper to get quick status of Harmonia on Onix
    cmd = ["ssh", "-o", "ConnectTimeout=2", "-o", "StrictHostKeyChecking=no", "-F", "/dev/null", "root@onix", "systemctl is-active harmonia.service"]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=2)
        return proc.stdout.strip()
    except Exception:
        return "offline"

def draw_dashboard(term_width, term_height):
    with STATE_LOCK:
        ruby_builds = list(ACTIVE_BUILDS["ruby"])
        sapphire_builds = list(ACTIVE_BUILDS["sapphire"])
        pulls = list(PARSED_PULLS)
        
    lines = []
    
    # Header
    title = " 󱄅 Nix Activity Monitor "
    border_len = max(10, term_width - len(title) - 2)
    left_border = "─" * (border_len // 2)
    right_border = "─" * (border_len - len(left_border))
    lines.append(f"{C_CYAN}{left_border}{C_BOLD}{C_YELLOW}{title}{C_RESET}{C_CYAN}{right_border}{C_RESET}")
    
    # Active Builds
    lines.append(f"\n{C_BOLD}🛠️  ACTIVE BUILDS{C_RESET}")
    
    # Ruby Panel
    ruby_count = len(ruby_builds) if (ruby_builds and "Offline" not in ruby_builds[0]) else 0
    if ruby_builds and ("Offline" in ruby_builds[0] or "Timeout" in ruby_builds[0]):
        ruby_header = f"  {C_RED}ruby (Offline){C_RESET}"
        ruby_details = []
    elif ruby_builds and "Error" in ruby_builds[0]:
        ruby_header = f"  {C_RED}ruby ({ruby_builds[0]}){C_RESET}"
        ruby_details = []
    else:
        status_color = C_GREEN if ruby_builds else C_GRAY
        ruby_header = f"  {status_color}● ruby{C_RESET} {C_GRAY}({ruby_count} building){C_RESET}"
        ruby_details = [f"    {C_DIM}└─{C_RESET} {b}" for b in ruby_builds] if ruby_builds else [f"    {C_DIM}No active builds{C_RESET}"]
        
    lines.append(ruby_header)
    for rd in ruby_details:
        lines.append(rd)
        
    # Sapphire Panel
    sapphire_count = len(sapphire_builds) if (sapphire_builds and "Offline" not in sapphire_builds[0]) else 0
    if sapphire_builds and ("Offline" in sapphire_builds[0] or "Timeout" in sapphire_builds[0]):
        sapphire_header = f"  {C_RED}sapphire (Offline){C_RESET}"
        sapphire_details = []
    elif sapphire_builds and "Error" in sapphire_builds[0]:
        sapphire_header = f"  {C_RED}sapphire ({sapphire_builds[0]}){C_RESET}"
        sapphire_details = []
    else:
        status_color = C_GREEN if sapphire_builds else C_GRAY
        sapphire_header = f"  {status_color}● sapphire{C_RESET} {C_GRAY}({sapphire_count} building){C_RESET}"
        sapphire_details = [f"    {C_DIM}└─{C_RESET} {b}" for b in sapphire_builds] if sapphire_builds else [f"    {C_DIM}No active builds{C_RESET}"]
        
    lines.append(sapphire_header)
    for sd in sapphire_details:
        lines.append(sd)
        
    # Onix Cache Activity
    lines.append(f"\n{C_BOLD}📦 ONIX CACHE LOGS (Harmonia){C_RESET}")
    if not pulls:
        lines.append(f"  {C_DIM}No recent pull logs found yet. Watching...{C_RESET}")
    else:
        # Show recent 15 pulls, newest at bottom
        recent_pulls = pulls[-15:]
        for p in recent_pulls:
            status_color = C_GREEN if p['status'] == 200 else C_RED
            status_text = "HIT " if p['status'] == 200 else "MISS"
            
            # Icon depending on type
            type_icon = "📄" if p['type'] == 'narinfo' else "📦"
            
            name = p['name']
            # Truncate name to fit terminal width
            max_name_len = term_width - 32
            if len(name) > max_name_len:
                name = name[:max_name_len-3] + "..."
                
            line = f"  {C_GRAY}{p['timestamp']}{C_RESET} {C_BOLD}{C_CYAN}{p['ip']:15}{C_RESET} {status_color}{status_text}{C_RESET} {type_icon} {name}"
            lines.append(line)
            
    # Footer
    lines.append("\n" + f"{C_GRAY}Press Ctrl+C to exit. Updates every 1s.{C_RESET}")
    
    # Render
    sys.stdout.write("\033[H\033[2J") # Clear screen
    sys.stdout.write("\n".join(lines) + "\n")
    sys.stdout.flush()

def main():
    global RUNNING
    
    # One-shot mode option
    one_shot = len(sys.argv) > 1 and sys.argv[1] in ("--one-shot", "-o")
    
    if one_shot:
        print(f"{C_BOLD}{C_CYAN}Querying Nix build and cache status...{C_RESET}\n")
        
        # Parallel query
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
            future_onix = executor.submit(get_onix_summary)
            future_ruby = executor.submit(query_builder, "ruby")
            future_sapphire = executor.submit(query_builder, "sapphire")
            
            onix_status = future_onix.result()
            ruby_builds = future_ruby.result()
            sapphire_builds = future_sapphire.result()
            
        print(f"{C_BOLD}🛠️  Active Builds:{C_RESET}")
        
        # Print Ruby
        if ruby_builds and ("Offline" in ruby_builds[0] or "Timeout" in ruby_builds[0]):
            print(f"  {C_RED}ruby (Offline){C_RESET}")
        else:
            status_color = C_GREEN if ruby_builds else C_GRAY
            print(f"  {status_color}● ruby{C_RESET} ({len(ruby_builds)} building):")
            for b in ruby_builds:
                print(f"    - {b}")
                
        # Print Sapphire
        if sapphire_builds and ("Offline" in sapphire_builds[0] or "Timeout" in sapphire_builds[0]):
            print(f"  {C_RED}sapphire (Offline){C_RESET}")
        else:
            status_color = C_GREEN if sapphire_builds else C_GRAY
            print(f"  {status_color}● sapphire{C_RESET} ({len(sapphire_builds)} building):")
            for b in sapphire_builds:
                print(f"    - {b}")
                
        # Print Onix Cache
        print(f"\n{C_BOLD}📦 Onix Binary Cache Status:{C_RESET}")
        onix_color = C_GREEN if onix_status == "active" else C_RED
        print(f"  Harmonia service is: {onix_color}{onix_status}{C_RESET}")
        
        # Fetch last 15 logs from Onix and resolve them
        print("\nRecent cache logs:")
        cmd = ["ssh", "-o", "ConnectTimeout=2", "-o", "StrictHostKeyChecking=no", "-F", "/dev/null", "root@onix", "tail -n 25 /var/log/nginx/harmonia.access.log 2>/dev/null || true"]
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=4)
            if proc.returncode == 0:
                lines = proc.stdout.strip().split('\n')
                parsed_items = []
                hashes_to_resolve = set()
                for line in lines:
                    entry = parse_log_line(line)
                    if entry:
                        parsed_items.append(entry)
                        if entry['hash']:
                            hashes_to_resolve.add(entry['hash'])
                            
                # Resolve hashes
                resolved = resolve_hashes_remote(hashes_to_resolve)
                for entry in parsed_items:
                    h = entry['hash']
                    name = resolved.get(h, h[:10] if h else "unknown")
                    status_color = C_GREEN if entry['status'] == 200 else C_RED
                    status_text = "HIT " if entry['status'] == 200 else "MISS"
                    type_icon = "📄" if entry['type'] == 'narinfo' else "📦"
                    print(f"  {C_GRAY}{entry['timestamp']}{C_RESET} {C_BOLD}{C_CYAN}{entry['ip']:15}{C_RESET} {status_color}{status_text}{C_RESET} {type_icon} {name}")
            else:
                print("  Failed to fetch logs from Onix.")
        except Exception as e:
            print(f"  Error fetching logs: {e}")
        return

    # Watch Mode (interactive TUI)
    # Start threads
    threads = [
        threading.Thread(target=onix_log_streamer, daemon=True),
        threading.Thread(target=hash_resolver_worker, daemon=True),
        threading.Thread(target=query_builders_loop, daemon=True)
    ]
    
    for t in threads:
        t.start()
        
    try:
        # Hide cursor
        sys.stdout.write("\033[?25l")
        sys.stdout.flush()
        
        while RUNNING:
            try:
                term_width, term_height = os.get_terminal_size()
            except Exception:
                term_width, term_height = 80, 24
                
            draw_dashboard(term_width, term_height)
            time.sleep(1.0)
    except KeyboardInterrupt:
        pass
    finally:
        RUNNING = False
        # Restore cursor
        sys.stdout.write("\033[?25h")
        sys.stdout.flush()
        print("\nExiting. Goodbye!")

if __name__ == "__main__":
    main()
