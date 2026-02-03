{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.cache;
in
{
  options.local.cache = {
    enable = lib.mkEnableOption "cache module";
    watch = lib.mkEnableOption "enable systemd service to watch cache";
    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "http://10.0.0.65:8080/main";
      description = "Attic binary cache server URL";
    };
    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "main:CqlQUu3twINKw6rrCtizlAYkrPOKUicoxMyN6EvYnbk=";
      description = "Public key for cache verification";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ attic-client ];
    systemd.user.services.attic-watch = lib.mkIf cfg.watch {
      Unit = {
        Description = "Watch Nix store and push to Attic cache";
        # HM will automatically link this to your graphical session if enabled
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        # We use the absolute path from the pkgs set to ensure it's always found
        ExecStart = "${pkgs.attic-client}/bin/attic watch-store main";
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    nix.settings = {
      trusted-users = [ "@wheel" ];
      substituters = [
        cfg.serverAddress
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        cfg.publicKey
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };
}
