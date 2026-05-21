{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "tgpt-auth";
  runtimeInputs = with pkgs; [ tgpt ];
  text = ''
    # Use the centralized secrets management path from the dotfiles
    GEMINI_KEY_PATH="$HOME/.secrets/gemini"
    
    if [ -f "$GEMINI_KEY_PATH" ]; then
      GEMINI_API_KEY=$(cat "$GEMINI_KEY_PATH")
      export GEMINI_API_KEY
    fi

    if [ -z "''${GEMINI_API_KEY:-}" ]; then
      echo "Error: Gemini API key not found at $GEMINI_KEY_PATH"
      exit 1
    fi

    exec tgpt -q --key "$GEMINI_API_KEY" --provider gemini --model gemini-3.5-flash "$@"
  '';
}
