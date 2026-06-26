import urllib.request
import re
import ssl
import hashlib
import base64
import json
import os
import urllib.parse

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

def process_files():
    urls = list_files(BASE_URL)
    # limit to 3 for testing
    urls = urls[:3]
    manifest = []
    for url in urls:
        print(f"Downloading {url} ...")
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            data = urllib.request.urlopen(req, context=ctx).read()
            h = hashlib.sha256(data).digest()
            sri = "sha256-" + base64.b64encode(h).decode("utf-8")
            
            name = urllib.parse.unquote(url.replace(BASE_URL, ""))
            manifest.append({
                "name": name,
                "url": url,
                "sha256": sri
            })
        except Exception as e:
            print(f"Error processing {url}: {e}")
    
    print(json.dumps(manifest, indent=2))

if __name__ == "__main__":
    process_files()
