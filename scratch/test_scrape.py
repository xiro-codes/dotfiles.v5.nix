import urllib.request
import urllib.error
import re
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def list_files(base_url):
    files = []
    try:
        html = urllib.request.urlopen(base_url, context=ctx).read().decode('utf-8')
        links = re.findall(r'href="([^"]+)"', html)
        for link in links:
            if link == "../": continue
            if link.endswith("/"):
                files.extend(list_files(base_url + link))
            else:
                files.append(base_url + link)
    except Exception as e:
        print(f"Error {base_url}: {e}")
    return files

print(list_files("https://icons.sapphire.home/"))
