import urllib.request
import re
import ssl
import hashlib
import base64
import json
import os
import urllib.parse
import concurrent.futures

BASE_URL = "https://wallpapers.sapphire.home/"

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def list_files(base_url):
    files = []
    try:
        req = urllib.request.Request(base_url, headers={'User-Agent': 'Mozilla/5.0'})
        html = urllib.request.urlopen(req, context=ctx).read().decode('utf-8')
        links = re.findall(r'href="([^"]+)"', html)
        for link in links:
            if link.startswith("?"): continue
            if link == "../": continue
            if link.endswith("/"):
                files.extend(list_files(base_url + link))
            else:
                files.append(base_url + link)
    except Exception as e:
        print(f"Error {base_url}: {e}")
    return files

def process_file(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = urllib.request.urlopen(req, context=ctx).read()
        h = hashlib.sha256(data).digest()
        sri = "sha256-" + base64.b64encode(h).decode("utf-8")
        
        name = urllib.parse.unquote(url.replace(BASE_URL, ""))
        return {
            "name": name,
            "url": url,
            "sha256": sri
        }
    except Exception as e:
        print(f"Error processing {url}: {e}")
        return None

def process_files():
    urls = list_files(BASE_URL)
    print(f"Found {len(urls)} wallpapers to process...")
    manifest = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        results = executor.map(process_file, urls)
        for r in results:
            if r:
                manifest.append(r)
    
    out_path = os.path.join(os.path.dirname(__file__), "manifest.json")
    with open(out_path, "w") as f:
        json.dump(manifest, f, indent=2)
    print(f"Saved manifest to {out_path}")

if __name__ == "__main__":
    process_files()
