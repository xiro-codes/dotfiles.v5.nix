{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.local.cache-server;
  hostsCfg = config.local.hosts;
in
{
  options.local.cache-server = {
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
    signKeyPath = mkOption {
      type = types.path;
      default = "";
      description = "secret key path";
    };
  };

  config = mkIf cfg.enable {
    services.harmonia = {
      enable = true;
      signKeyPath = cfg.signKeyPath;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

  };
}
