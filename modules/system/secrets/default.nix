{ config, lib, pkgs, ... }:
let
  cfg = config.local.secrets;
in
{
  options.local.secrets = {
    enable = lib.mkEnableOption "sops-nix secret management";
    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../../secrets/secrets.yaml;
      description = "Path to the encrypted yaml file";
    };
    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of sops keys to automatically map to /.secrets/";
    };
  };
  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = cfg.sopsFile;
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets = lib.genAttrs cfg.keys
        (name: {
          mode = "0440";
          owner = "root";
          group = "wheel";
          path = "/.secrets/${name}";
        });
    };
  };
}
