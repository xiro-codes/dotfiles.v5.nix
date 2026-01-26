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
    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "http://10.0.0.65:8080/main";
    };
    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "main:CqlQUu3twINKw6rrCtizlAYkrPOKUicoxMyN6EvYnbk=";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ attic-client ];
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
