{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.harmonia-cache;
in
{
  options.local.harmonia-cache = {
    enable = mkEnableOption "Attic binary cache server";

    port = mkOption {
      type = types.port;
      default = 5000;
      description = "HTTP port for cache server";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "open firewall";
    };
    signKeyPaths = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = "secret key paths";
    };
    prefetch = {
      enable = mkEnableOption "Enable prefetch";
      path = mkOption {
        type = types.path;
        default = "/etc/nixos";
        description = "path of your flake";
      };
      schedule = mkOption {
        type = types.str;
        default = "03:00";
        description = "In Systemd timer format";
      };
      hostNames = mkOption {
        type = types.listOf types.str;
        default = [
          "Onix"
          "Ruby"
          "Sapphire"
        ];
        description = "System Configurations to prefetch";
      };
    };
  };

  config = mkIf cfg.enable {
    services.harmonia.cache = {
      enable = true;
      signKeyPaths = cfg.signKeyPaths;
    };
    systemd.services.nix-prefetch = mkIf cfg.prefetch.enable {
      description = "Pre fetch flake updates and store paths";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script =
        let
          prefetchScript = self.packages.${pkgs.stdenv.hostPlatform.system}.harmonia-prefetch;
        in
        "${prefetchScript}/bin/prefetch ${cfg.prefetch.path} ${builtins.concatStringsSep " " cfg.prefetch.hostNames}";
    };
    systemd.timers.nix-prefetch = {
      description = "Timer for Nix pre-fetch";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        # Example: Run every night at 3:00 AM
        OnCalendar = cfg.prefetch.schedule;
        Persistent = true;
      };
    };
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
