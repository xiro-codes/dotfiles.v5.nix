{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "video-to-gif";
  runtimeInputs = with pkgs; [ ffmpeg ];
  text = ''
    if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
      echo "Usage: video-to-gif <input_video> [output_gif]"
      echo "Converts a video to a high-quality GIF."
      exit 1
    fi

    INPUT="$1"
    
    if [ ! -f "$INPUT" ]; then
      echo "Error: Input file '$INPUT' not found."
      exit 1
    fi

    if [ "$#" -ge 2 ]; then
      OUTPUT="$2"
    else
      # Strip extension and add .gif
      OUTPUT="''${INPUT%.*}.gif"
    fi

    echo "Converting '$INPUT' to '$OUTPUT'..."
    
    # Generate palette for better colors, then use it to create gif
    # We use a temporary palette file
    PALETTE=$(mktemp /tmp/palette_XXXXXX.png)
    
    # Default to 15 fps and scale to max 800px width (maintaining aspect ratio)
    FILTERS="fps=15,scale='min(800,iw)':-1:flags=lanczos"
    
    echo "Step 1/2: Generating color palette..."
    ffmpeg -v warning -i "$INPUT" -vf "$FILTERS,palettegen" -y "$PALETTE"
    
    echo "Step 2/2: Generating GIF..."
    ffmpeg -v warning -i "$INPUT" -i "$PALETTE" -lavfi "$FILTERS [x]; [x][1:v] paletteuse" -y "$OUTPUT"
    
    rm "$PALETTE"
    
    echo "Done! Saved to $OUTPUT"
  '';
}
