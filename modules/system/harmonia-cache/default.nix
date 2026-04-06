{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.local.harmonia-cache;
  hostsCfg = config.local.hosts;
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
  };

  config = mkIf cfg.enable {
    services.harmonia.cache = {
      enable = true;
      signKeyPaths = cfg.signKeyPaths;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

  };
}
