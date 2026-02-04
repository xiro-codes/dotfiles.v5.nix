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
      example = lib.literalExpression "../secrets/system-secrets.yaml";
      description = "Path to the encrypted YAML file containing system secrets";
    };
    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "onix_creds" "ssh_pub_ruby/master" "ssh_pub_sapphire/master" ];
      description = "List of sops keys to automatically map to /run/secrets/ for system-wide access";
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
        });
    };
  };
}
