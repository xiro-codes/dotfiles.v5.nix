{ config, pkgs, lib, ... }:
let
  cfg = config.local.ssh;
  user = config.home.username;
in
{
  options.local.ssh = {
    enable = lib.mkEnableOption "configure ssh for user";
    masterKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.ssh/id_ed25519";
      description = "Fixed path to the private master key.";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        Sapphire = "10.0.0.67";
        Ruby = "10.0.0.66";
      };
      description = "Mapping of aliases to hostnames/IPs.";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      enableDefaultConfig = false;
      # Dynamically generate matchBlocks from the hosts option
      matchBlocks = (lib.mapAttrs
        (alias: host: {
          hostname = host;
          user = user;
          identityFile = cfg.masterKeyPath;
          forwardAgent = true;
        })
        cfg.hosts) // {
        # Static entries like GitHub
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/github";
        };
        "gitea" = {
          hostname = "10.0.0.65";
          port = 222;
          user = "git";
          identityFile = "~/.ssh/github";
        };
        # Default wildcard ensures your user is always used for unknown hosts
        "*" = {
          user = user;
          addKeysToAgent = "yes";
          controlMaster = "auto";
          controlPath = "~/.ssh/master-%r@%h:%p";
          setEnv = { TERM = "xterm-256color"; };
        };
      };
    };
  };
}

