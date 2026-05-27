{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "gemini-video-gen";
  runtimeInputs = with pkgs; [
    python3
  ];
  text = ''
    exec python3 ${./gemini-video-gen.py} "$@"
  '';
}
