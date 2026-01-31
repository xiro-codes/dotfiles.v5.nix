{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.local.secrets;
in
{
  options.local.secrets = {
    enable = lib.mkEnableOption "Use secrets";
    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../../secrets/secrets.yaml;
      description = "Path to the encrypted yaml file";
    };
    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List sops keys to automatically map to $HOME/.secrets/";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "user-sops" ''
        export SOPS_AGE_KEY=$(${lib.getExe ssh-to-age} -private-key -i $HOME/.ssh/id_sops)
        if [ -z "$SOPS_AGE_KEY" ]; then
          echo "Error: Could not derive Age key from $HOME/.ssh/id_sops"
          exit 1
        fi
        exec ${lib.getExe sops} "$@"
      '')
    ];
    sops = {
      age.sshKeyPaths = [ "/home/tod/.ssh/id_sops" ];
      defaultSopsFile = cfg.sopsFile;
      secrets = lib.genAttrs cfg.keys
        (name: {
          mode = "0400";
          path = "${config.home.homeDirectory}/.secrets/${name}";
        });
    };

  };
}








