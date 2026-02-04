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
      default = "http://${config.local.hosts.onix}:8080/main?priority=1";
      example = "http://cache.example.com:8080/nixos?priority=10";
      description = "Attic binary cache server URL with optional priority parameter";
    };
    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "main:CqlQUu3twINKw6rrCtizlAYkrPOKUicoxMyN6EvYnbk=";
      example = "cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz==";
      description = "Public key for cache verification";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ attic-client ];
    nix.settings = {
      trusted-users = [ "@wheel" ];
      substituters = [
        cfg.serverAddress
        #"https://cache.nixos.org?priority=100"
      ];
      trusted-public-keys = [
        cfg.publicKey
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };
}
