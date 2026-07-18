{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "github-to-gitea";
  runtimeInputs = [
    (pkgs.python3.withPackages (ps: with ps; [ requests ]))
  ];
  text = ''
    exec python3 ${./github-to-gitea.py} "$@"
  '';
}
