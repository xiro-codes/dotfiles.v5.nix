#!/usr/bin/env python3
"""
nix-build-log: Stream live build output from a remote or local Nix builder.

Usage:
  nix-build-log [ruby|sapphire]  - Stream from a specific host
  nix-build-log                  - Auto-detect any active build
"""

import re
import sys
import time
import subprocess
import codecs
import json

# ── SSH and Command helpers ──────────────────────────────────────────────────

SSH_OPTS = ["-o", "ConnectTimeout=2", "-o", "StrictHostKeyChecking=no", "-F", "/dev/null"]
HOSTS    = ["sapphire", "ruby"]

def ssh_run(host, script, timeout=4):
    cmd = ["ssh"] + SSH_OPTS + [f"root@{host}", "sh"]
    try:
        proc = subprocess.run(cmd, input=script, capture_output=True, text=True, timeout=timeout)
        return proc.stdout.strip() if proc.returncode == 0 else None
    except Exception:
        return None

# ── Build discovery ───────────────────────────────────────────────────────────

# Find the topmost sandboxed builder process and return its parent PPID (the host driver process)
_FIND_BUILD = """
top_pid=""
parent_pid=""
top_name=""
for env_file in /proc/*/environ; do
  if [ -f "$env_file" ] && grep -q -a "NIX_BUILD_TOP=" "$env_file" 2>/dev/null; then
    pid=$(echo "$env_file" | cut -d/ -f3)
    ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    
    parent_has_top=0
    if [ -n "$ppid" ] && [ -f "/proc/$ppid/environ" ]; then
      if grep -q -a "NIX_BUILD_TOP=" "/proc/$ppid/environ" 2>/dev/null; then
        parent_has_top=1
      fi
    fi
    
    if [ "$parent_has_top" -eq 0 ]; then
      name=$(tr '\\0' '\\n' < "$env_file" | grep -a '^name=' | cut -d= -f2-)
      [ -z "$name" ] && name="build-$pid"
      top_pid=$pid
      parent_pid=$ppid
      top_name=$name
      break
    fi
  fi
done

if [ -n "$top_pid" ] && [ -n "$parent_pid" ]; then
  echo "$parent_pid|$top_name"
fi
"""

def find_active_build(host):
    out = ssh_run(host, _FIND_BUILD)
    if out:
        parts = out.split("|", 1)
        if len(parts) == 2:
            return parts[0].strip(), parts[1].strip()
    return None

# ── Log parsing ───────────────────────────────────────────────────────────────

_ANSI_RE       = re.compile(r'\x1b\[[0-9;]*m|\x1b\[[0-9;]*[A-Za-z]')
_PROGRESS_RE   = re.compile(r'^\[\d+/\d+\]')
_WRITE_RE      = re.compile(r'^(?:\[pid\s+\d+\]\s+)?write\((\d+),\s*"((?:[^"\\]|\\.)*?)"(?:\.\.\.)?,\s*\d+\)')
_PKG_PREFIX_RE = re.compile(r'^[a-zA-Z0-9_\-\.]+>\s*')

def parse_line(raw):
    """Extract and unescape text from a strace write() line."""
    m = _WRITE_RE.match(raw)
    if not m:
        return None
    fd = m.group(1)
    raw_str = m.group(2)
    try:
        decoded_bytes, _ = codecs.escape_decode(raw_str.encode('utf-8'))
        decoded = decoded_bytes.decode('utf-8', errors='replace')
    except Exception:
        # Fallback manual decode
        decoded = (raw_str.replace('\\n', '\n')
                          .replace('\\t', '\t')
                          .replace('\\"', '"')
                          .replace('\\\\', '\\')
                          .replace('\\r', ''))

    # Check if the decoded payload is JSON (from nix-daemon JSON log socket)
    stripped = decoded.strip()
    if stripped.startswith('{') and stripped.endswith('}'):
        try:
            data = json.loads(stripped)
            if "fields" in data and isinstance(data["fields"], list):
                text = " ".join(str(f) for f in data["fields"]).strip()
                if text:
                    return text
            if "msg" in data:
                return str(data["msg"]).strip()
        except Exception:
            pass

    # If it is fd 1 or 2 (stdout/stderr of nix client), return the text directly
    if fd in ("1", "2"):
        # Strip package prefix (e.g. "ffmpeg> ") for clean styling
        cleaned = _PKG_PREFIX_RE.sub('', decoded)
        return cleaned

    return None

# ── Colors ────────────────────────────────────────────────────────────────────

C_RESET  = "\033[0m"
C_BOLD   = "\033[1m"
C_DIM    = "\033[2m"
C_GRAY   = "\033[90m"
C_GREEN  = "\033[38;2;166;226;46m"
C_RED    = "\033[38;2;249;38;114m"
C_CYAN   = "\033[38;2;102;217;239m"
C_YELLOW = "\033[38;2;230;219;116m"

# ── Streaming ─────────────────────────────────────────────────────────────────

def stream(host, pid, drv_name):
    print(f"{C_BOLD}{C_GREEN}▶  {drv_name}{C_RESET}")
    print(f"{C_DIM}   host={host}  driver-pid={pid}{C_RESET}")
    print(f"{C_GRAY}   Ctrl+C to stop{C_RESET}\n")

    strace_cmd = f"strace -p {pid} -s 8192 -e write 2>&1"
    cmd = ["ssh"] + SSH_OPTS + [f"root@{host}", strace_cmd]

    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True, errors="replace")
        for raw in proc.stdout:
            raw = raw.strip()
            if not raw:
                continue
            if "attached" in raw or "detached" in raw:
                continue
            msg = parse_line(raw)
            if not msg:
                continue
            for line in msg.splitlines():
                line = line.strip()
                if not line:
                    continue
                # Strip ANSI colors if present
                line = _ANSI_RE.sub('', line).strip()
                if not line:
                    continue
                # Style and output
                if "[1/2]" in line or "[2/2]" in line or _PROGRESS_RE.match(line):
                    sys.stdout.write(f"{C_CYAN}{line}{C_RESET}\n")
                elif "warning:" in line.lower() or "error:" in line.lower():
                    sys.stdout.write(f"{C_YELLOW}{line}{C_RESET}\n")
                else:
                    sys.stdout.write(f"{C_DIM}{line}{C_RESET}\n")
                sys.stdout.flush()
    except KeyboardInterrupt:
        print(f"\n{C_YELLOW}Stopped.{C_RESET}")
    except Exception as exc:
        print(f"\n{C_RED}Error: {exc}{C_RESET}")

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    host_arg = sys.argv[1] if len(sys.argv) > 1 else None

    if host_arg and host_arg not in HOSTS:
        print(f"{C_RED}Unknown host '{host_arg}'. Use: {', '.join(HOSTS)}{C_RESET}")
        sys.exit(1)

    search = [host_arg] if host_arg else HOSTS

    print(f"{C_CYAN}Waiting for an active build on {', '.join(search)}…{C_RESET}")
    try:
        while True:
            for host in search:
                res = find_active_build(host)
                if res:
                    pid, drv_name = res
                    stream(host, pid, drv_name)
                    return
            time.sleep(0.5)
    except KeyboardInterrupt:
        print(f"\n{C_YELLOW}Exiting.{C_RESET}")

if __name__ == "__main__":
    main()
