#!/usr/bin/env python3
import argparse
import json
import os
import sys
import time
import urllib.request
import urllib.error

def make_request(url, headers, data=None, method="GET"):
    req = urllib.request.Request(url, headers=headers, method=method)
    if data is not None:
        req.data = json.dumps(data).encode("utf-8")
        req.add_header("Content-Type", "application/json")
    
    try:
        with urllib.request.urlopen(req) as response:
            return response.read(), response.status
    except urllib.error.HTTPError as e:
        error_msg = e.read().decode("utf-8", errors="ignore")
        print(f"HTTP Error {e.code}: {e.reason}", file=sys.stderr)
        try:
            err_json = json.loads(error_msg)
            print(json.dumps(err_json, indent=2), file=sys.stderr)
        except Exception:
            print(error_msg, file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Network error: {e}", file=sys.stderr)
        sys.exit(1)

def download_file(url, headers, output_path):
    print(f"Downloading video from {url} to {output_path}...")
    req = urllib.request.Request(url, headers=headers, method="GET")
    try:
        with urllib.request.urlopen(req) as response:
            with open(output_path, "wb") as f:
                total_size = int(response.info().get('Content-Length', 0))
                downloaded = 0
                while True:
                    chunk = response.read(8192)
                    if not chunk:
                        break
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\rDownloading: {percent:.1f}% ({downloaded}/{total_size} bytes)", end="")
                    else:
                        print(f"\rDownloading: {downloaded} bytes", end="")
                print("\nDownload complete!")
    except urllib.error.HTTPError as e:
        # Fallback if redirect doesn't accept custom headers
        if "key" in url or "signature" in url or "GoogleAccessId" in url:
            try:
                with urllib.request.urlopen(url) as response:
                    with open(output_path, "wb") as f:
                        f.write(response.read())
                print("Download complete (without headers fallback)!")
                return
            except Exception:
                pass
        print(f"HTTP Error downloading file {e.code}: {e.reason}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error downloading file: {e}", file=sys.stderr)
        sys.exit(1)

def extract_video_uri(data):
    try:
        return data["response"]["generateVideoResponse"]["generatedSamples"][0]["video"]["uri"]
    except KeyError:
        pass
    
    try:
        return data["response"]["generatedSamples"][0]["video"]["uri"]
    except KeyError:
        pass

    try:
        return data["generatedSamples"][0]["video"]["uri"]
    except KeyError:
        pass
    
    return None

def main():
    parser = argparse.ArgumentParser(description="Generate a video using Gemini Veo API key.")
    parser.add_argument("-p", "--prompt", required=True, help="Text prompt to generate video from.")
    parser.add_argument("-o", "--output", default="output.mp4", help="Output path for the generated video (default: output.mp4).")
    parser.add_argument("-m", "--model", default="veo-2.0-generate-001", help="Model to use (default: veo-2.0-generate-001).")
    parser.add_argument("-d", "--duration", type=int, default=5, help="Duration of the video in seconds (default: 5).")
    parser.add_argument("-a", "--aspect-ratio", default="16:9", choices=["16:9", "9:16", "1:1"], help="Aspect ratio (default: 16:9).")
    parser.add_argument("-r", "--resolution", default="720p", choices=["720p", "1080p"], help="Resolution (default: 720p).")
    parser.add_argument("--key", help="Gemini API key. If not provided, GEMINI_API_KEY or GOOGLE_API_KEY environment variable will be used.")
    
    args = parser.parse_args()
    
    api_key = args.key or os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        print("Error: Gemini API key not found. Set the GEMINI_API_KEY or GOOGLE_API_KEY environment variable, or pass it via --key.", file=sys.stderr)
        sys.exit(1)
        
    headers = {
        "x-goog-api-key": api_key,
    }
    
    # 1. Initiate long running video generation
    start_url = f"https://generativelanguage.googleapis.com/v1beta/models/{args.model}:predictLongRunning"
    payload = {
        "instances": [
            {
                "prompt": args.prompt
            }
        ],
        "parameters": {
            "sampleCount": 1,
            "aspectRatio": args.aspect_ratio,
            "resolution": args.resolution,
            "durationSeconds": args.duration
        }
    }
    
    print(f"Initiating video generation with model '{args.model}'...")
    print(f"Prompt: '{args.prompt}'")
    print(f"Parameters: Duration={args.duration}s, Aspect Ratio={args.aspect_ratio}, Resolution={args.resolution}")
    
    resp_body, status = make_request(start_url, headers, data=payload, method="POST")
    resp_json = json.loads(resp_body.decode("utf-8"))
    
    op_name = resp_json.get("name")
    if not op_name:
        print("Error: Could not retrieve operation name from response:", file=sys.stderr)
        print(json.dumps(resp_json, indent=2), file=sys.stderr)
        sys.exit(1)
        
    print(f"Operation started: {op_name}")
    
    # 2. Poll the operation
    poll_url = f"https://generativelanguage.googleapis.com/v1beta/{op_name}"
    
    print("Waiting for generation to complete (this may take a few minutes)...")
    wait_time = 15
    while True:
        poll_resp, poll_status = make_request(poll_url, headers)
        poll_json = json.loads(poll_resp.decode("utf-8"))
        
        is_done = poll_json.get("done", False)
        if is_done:
            print("\nOperation complete!")
            if "error" in poll_json:
                print("Error in generation operation:", file=sys.stderr)
                print(json.dumps(poll_json["error"], indent=2), file=sys.stderr)
                sys.exit(1)
            
            video_uri = extract_video_uri(poll_json)
            if not video_uri:
                print("Error: Could not extract video URI from operation response:", file=sys.stderr)
                print(json.dumps(poll_json, indent=2), file=sys.stderr)
                sys.exit(1)
                
            # 3. Download the video file
            download_file(video_uri, headers, args.output)
            break
        else:
            print(".", end="", flush=True)
            time.sleep(wait_time)

if __name__ == "__main__":
    main()
