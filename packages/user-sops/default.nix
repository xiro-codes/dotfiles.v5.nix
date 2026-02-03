{ pkgs, lib }:

pkgs.writeShellScriptBin "user-sops" ''
  export SOPS_AGE_KEY=$(${lib.getExe pkgs.ssh-to-age} -private-key -i $HOME/.ssh/id_sops)
  if [ -z "$SOPS_AGE_KEY" ]; then
    echo "Error: Could not derive Age key from $HOME/.ssh/id_sops"
    exit 1
  fi
  exec ${lib.getExe pkgs.sops} "$@"
''
