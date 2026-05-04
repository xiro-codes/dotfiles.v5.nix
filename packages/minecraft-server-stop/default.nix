{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "minecraft-server-stop";
  text = ''
    FIFO=$1
    PID=$2
    echo stop > "$FIFO"
    while kill -0 "$PID" 2> /dev/null; do
      sleep 1s
    done
  '';
}
