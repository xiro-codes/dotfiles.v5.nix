{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    getExe
    ;

  cfg = config.local.harmonia-client;
  hostsCfg = config.local.network-hosts;
  primaryHost = hostsCfg.primary;
  primaryIp = hostsCfg.${primaryHost};
in
{
  options.local.harmonia-client = {
    enable = mkEnableOption "Harmonia cache client module";
    serverAddress = mkOption {
      type = types.str;
      default = "http://${primaryIp}:5000/?priority=1";
      example = "http://cache.example.com:8080/nixos?priority=10";
      description = "Attic binary cache server URL with optional priority parameter";
    };
    publicKey = mkOption {
      type = types.str;
      default = "";
      example = "cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz==";
      description = "Public key for cache verification";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ harmonia-upload-hook ];
    environment.etc."harmonia-upload-host.conf".text = primaryIp;
    nix.settings = {
      post-build-hook = lib.getExe pkgs.harmonia-upload-hook;
      trusted-users = [ "@wheel" ];
      substituters = [
        cfg.serverAddress
        "https://cache.nixos.org?priority=100"
      ];
      trusted-public-keys = (if cfg.publicKey != "" then [ cfg.publicKey ] else []) ++ [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      connect-timeout = 3;
      stalled-download-timeout = 15;
      download-attempts = 2;
    };
  };
}
