{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "mc-console";
  text = ''
    set -euo pipefail

    FIFO="/run/minecraft-server.stdin"
    SERVICE="minecraft-server.service"

    # Check if server is running
    if ! systemctl is-active --quiet "$SERVICE"; then
      echo "Error: Minecraft server is not running."
      exit 1
    fi

    if [ "$1" = "rcon" ]; then
      PORT=$2
      PASSWORD=$3
      echo "Connecting via RCON..."
      exec ${pkgs.mcrcon}/bin/mcrcon \
        -H localhost \
        -P "$PORT" \
        -p "$PASSWORD" \
        -t
    else
      if [[ ! -p "$FIFO" ]]; then
        echo "Error: FIFO $FIFO not found. Is the server running correctly?"
        exit 1
      fi

      echo "Connecting to Minecraft Server Console (Journal + FIFO)..."
      echo "Type commands and press Enter. Press Ctrl+C to exit."
      echo "----------------------------------------------------"

      ${pkgs.systemd}/bin/journalctl -u "$SERVICE" -f -n 50 &
      JOURNAL_PID=$!

      # shellcheck disable=SC2064
      trap "kill $JOURNAL_PID 2>/dev/null; echo; exit 0" SIGINT SIGTERM

      while IFS= read -r line; do
        echo "$line" > "$FIFO"
      done
    fi
  '';
}
