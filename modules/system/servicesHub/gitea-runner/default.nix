{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.gitea-runner;
  giteaCfg = config.local.gitea;
in
{
  options.local.gitea-runner = {
    enable = mkEnableOption "Gitea Actions Runner";

    instanceName = mkOption {
      type = types.str;
      default = "default-runner";
      description = "Name of the runner instance";
    };

    giteaUrl = mkOption {
      type = types.str;
      default =
        if giteaCfg.enable then "http://127.0.0.1:${toString giteaCfg.port}" else "http://127.0.0.1:3001";
      description = "URL of the Gitea instance to connect to";
    };

    tokenFile = mkOption {
      type = types.str;
      # Assumes sops secret exists at this path by default, but can be overridden
      default = "/run/secrets/gitea/runner_token";
      description = "Path to the file containing the runner registration token";
    };

    labels = mkOption {
      type = types.listOf types.str;
      default = [
        "ubuntu-latest:docker://node:18-bullseye"
        "ubuntu-22.04:docker://node:18-bullseye"
        "ubuntu-20.04:docker://node:16-bullseye"
        "nixos-latest:docker://nixos/nix:latest"
      ];
      description = "Labels for the runner";
    };
  };

  config = mkIf cfg.enable {
    # Use Podman with Docker compatibility
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      #defaultNetwork.settings.dns_enabled = fa;
    };

    services.gitea-actions-runner = {
      package = pkgs.gitea-actions-runner;
      instances.${cfg.instanceName} = {
        enable = true;
        name = cfg.instanceName;
        url = cfg.giteaUrl;
        token = "HzO7Yi38427r000XXA1KqgX48blsyfjMIz60CK1j";
        labels = cfg.labels;
        settings = {
          log.level = "info";
        };
      };
    };
  };
}
