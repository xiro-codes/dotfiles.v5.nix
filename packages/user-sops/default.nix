{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;
in
pkgs.writeShellApplication {
  name = "user-sops";
  text = ''
    SOPS_AGE_KEY=$(${getExe pkgs.ssh-to-age} -private-key -i "$HOME"/.ssh/id_sops)
    export SOPS_AGE_KEY
    if [ -z "$SOPS_AGE_KEY" ]; then
      echo "Error: Could not derive Age key from $HOME/.ssh/id_sops"
      exit 1
    fi
    exec ${getExe pkgs.sops} "$@"
  '';
}
