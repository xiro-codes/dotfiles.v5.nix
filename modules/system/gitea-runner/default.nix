{ config, lib, pkgs, ... }:

let
  cfg = config.local.gitea-runner;
  giteaCfg = config.local.gitea;
in
{
  options.local.gitea-runner = {
    enable = lib.mkEnableOption "Gitea Actions Runner";

    instanceName = lib.mkOption {
      type = lib.types.str;
      default = "default-runner";
      description = "Name of the runner instance";
    };

    giteaUrl = lib.mkOption {
      type = lib.types.str;
      default = if giteaCfg.enable then "http://127.0.0.1:${toString giteaCfg.port}" else "http://127.0.0.1:3001";
      description = "URL of the Gitea instance to connect to";
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      # Assumes sops secret exists at this path by default, but can be overridden
      default = config.sops.secrets."gitea/runner_token".path;
      description = "Path to the file containing the runner registration token";
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ 
        "ubuntu-latest:docker://node:18-bullseye"
        "ubuntu-22.04:docker://node:18-bullseye"
        "ubuntu-20.04:docker://node:16-bullseye"
      ];
      description = "Labels for the runner";
    };
  };

  config = lib.mkIf cfg.enable {
    # Runner typically requires container runtime
    virtualisation.docker.enable = true;

    services.gitea-actions-runner = {
      package = pkgs.gitea-actions-runner;
      instances.${cfg.instanceName} = {
        enable = true;
        name = cfg.instanceName;
        url = cfg.giteaUrl;
        tokenFile = cfg.tokenFile;
        labels = cfg.labels;
        settings = {
          log.level = "info";
        };
      };
    };
  };
}
