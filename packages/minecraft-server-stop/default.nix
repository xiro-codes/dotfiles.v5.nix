{ pkgs, ... }:
pkgs.writeShellScriptBin "minecraft-server-stop" ''
  FIFO=$1
  PID=$2
  echo stop > "$FIFO"
  while kill -0 "$PID" 2> /dev/null; do
    sleep 1s
  done
''
