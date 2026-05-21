{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "hypr-screenshot";
  runtimeInputs = with pkgs; [
    grim
    slurp
    hyprland
    jq
    wl-clipboard
    libnotify
    tgpt
  ];
  text = ''
    # Config
    SAVE_DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$SAVE_DIR"

    # Load API Key
    GEMINI_KEY_PATH="$HOME/.secrets/gemini"
    if [ -f "$GEMINI_KEY_PATH" ]; then
      GEMINI_API_KEY=$(cat "$GEMINI_KEY_PATH")
      export GEMINI_API_KEY
    fi

    # Get window titles for context
    ACTIVE_WS=$(hyprctl activeworkspace -j | jq '.id')
    WINDOW_INFO=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $ACTIVE_WS) | .title" | head -n 5)
    
    # Select area
    MODE="''${1:-area}"
    if [ "$MODE" = "full" ]; then
      GEOM=""
    else
      GEOM=$(slurp)
    fi

    if [ -z "$GEOM" ] && [ "$MODE" != "full" ]; then
      exit 0
    fi

    # Temporary file
    TEMP_FILE=$(mktemp /tmp/screenshot_XXXXXX.png)
    
    if [ -n "$GEOM" ]; then
      grim -g "$GEOM" "$TEMP_FILE"
    else
      grim "$TEMP_FILE"
    fi

    # AI Naming Logic (Text-only context)
    FILENAME=""
    if [ -n "''${GEMINI_API_KEY:-}" ]; then
      PROMPT="You are a file naming assistant. Based on these window titles: '$WINDOW_INFO', generate a very short (1-3 words), slugified filename for a screenshot. Output ONLY the slug, no extension, no explanation. Example: coding-neovim or discord-chat."
      
      FILENAME=$(tgpt -q --key "$GEMINI_API_KEY" --provider gemini --model gemini-3.5-flash "$PROMPT" 2>/dev/null || echo "")
    fi

    if [ -z "$FILENAME" ] || [ "$FILENAME" = "null" ]; then
      FILENAME="screenshot-$(date +%Y%m%d-%H%M%S)"
    else
      # Sanitize AI output
      FILENAME=$(echo "$FILENAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
      FILENAME="''${FILENAME}-$(date +%H%M%S)"
    fi

    FINAL_PATH="$SAVE_DIR/$FILENAME.png"
    mv "$TEMP_FILE" "$FINAL_PATH"

    # Copy to clipboard
    wl-copy < "$FINAL_PATH"

    # Notify
    notify-send "Screenshot Captured" "Saved as $FILENAME.png" -i "$FINAL_PATH"
  '';
}
