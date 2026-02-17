{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.cache-server;
  hostsCfg = config.local.hosts;
in
{
  options.local.cache-server = {
    enable = lib.mkEnableOption "Attic binary cache server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "HTTP port for cache server";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "open firewall";
    };
    signKeyPath = lib.mkOption {
      type = lib.types.path;
      default = "";
      description = "secret key path";
    };
  };

  config = lib.mkIf cfg.enable {
    services.harmonia = {
      enable = true;
      signKeyPath = cfg.signKeyPath;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

  };
}
