{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "nix-activity";
  runtimeInputs = with pkgs; [
    openssh
    python3
  ];
  text = ''
    exec python3 ${./nix-activity.py} "$@"
  '';
}
