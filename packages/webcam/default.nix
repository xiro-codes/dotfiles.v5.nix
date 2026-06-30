{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "webcam";
  runtimeInputs = with pkgs; [ mpv ];
  text = ''
    VIDEO_DEVICE=""

    # Check for /dev/video0 first
    if [ -e "/dev/video0" ]; then
      VIDEO_DEVICE="/dev/video0"
    else
      # Fallback to the first available /dev/video*
      for dev in /dev/video*; do
        if [ -e "$dev" ]; then
          VIDEO_DEVICE="$dev"
          break
        fi
      done
    fi

    if [ -z "$VIDEO_DEVICE" ]; then
      echo "Error: No video device found in /dev/"
      exit 1
    fi

    echo "Using video device: $VIDEO_DEVICE"
    
    # Run mpv with the specified arguments
    exec mpv "$VIDEO_DEVICE" \
      --no-osc \
      --no-osd-bar \
      --no-border \
      --wayland-app-id="webcam"
  '';
}
