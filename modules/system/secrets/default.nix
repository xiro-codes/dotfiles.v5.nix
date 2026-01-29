{ config, lib, pkgs, ... }:
let
  cfg = config.local.secrets;
in
{
  option.local.secrets = {
    enable = lib.mkEnableOption "sops-nix secret management";
    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../../secrets/secrets.yaml;
      description = "Path to the encrypted yaml file";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackage = [ pkgs.sops ];
    sops = {
      defaultSopsFile = cfg.sopsFile;
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets = {
        "gemini/api_key" = {
          owner = "root";
          group = "wheel";
          mode = "0440";
        };
        "attic/api_key" = {
          owner = "root";
          group = "wheel";
          mode = "0440";
        };
      };
    };
  };
}
