{ config, lib, pkgs, ... }:
let
  inherit (lib) genAttrs literalExpression mkEnableOption mkIf mkOption types;

  cfg = config.local.secrets;
in
{
  options.local.secrets = {
    enable = mkEnableOption "sops-nix secret management";
    sopsFile = mkOption {
      type = types.path;
      default = ../../../secrets/secrets.yaml;
      example = literalExpression "../secrets/system-secrets.yaml";
      description = "Path to the encrypted YAML file containing system secrets";
    };
    keys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "onix_creds" "ssh_pub_ruby/master" "ssh_pub_sapphire/master" ];
      description = "List of sops keys to automatically map to /run/secrets/ for system-wide access";
    };
  };
  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = cfg.sopsFile;
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets = genAttrs cfg.keys
        (name: {
          mode = "0440";
          owner = "root";
          group = "wheel";
        });
    };
  };
}
