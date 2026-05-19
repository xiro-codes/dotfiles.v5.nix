{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "nix-build-log";
  runtimeInputs = with pkgs; [
    openssh
    python3
  ];
  text = ''
    exec python3 ${./nix-build-log.py} "$@"
  '';
}
