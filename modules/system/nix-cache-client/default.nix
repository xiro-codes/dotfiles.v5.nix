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
    ;

  cfg = config.local.nix-cache-client;
  hostsCfg = config.local.network-hosts;
  primaryHost = hostsCfg.primary;
  primaryIp = hostsCfg.${primaryHost};
in
{
  options.local.nix-cache-client = {
    enable = mkEnableOption "cache module";
    serverAddress = mkOption {
      type = types.str;
      default = "http://${primaryIp}:5000/?priority=1";
      example = "http://cache.example.com:8080/nixos?priority=10";
      description = "Attic binary cache server URL with optional priority parameter";
    };
    publicKey = mkOption {
      type = types.str;
      default = "cache.onix.home-1:/M1y/hGaD/dB8+mDfZmMdtXaWjq7XtLc1GMycddoNIE=";
      example = "cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz==";
      description = "Public key for cache verification";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ];
    nix.settings = {
      post-build-hook =
        let
          uploadScript = pkgs.writeShellScript "upload-to-cache" ''
            set -eu
            if [ -n "''${OUT_PATHS:-}" ]; then
              echo "Uploading to ${primaryHost} cache: $OUT_PATHS"
              # shellcheck disable=SC2086
              ${pkgs.nix}/bin/nix copy --to http://${primaryIp}:5000 $OUT_PATHS || true
            fi
          '';
        in
        "${uploadScript}";
      trusted-users = [ "@wheel" ];
      substituters = [
        cfg.serverAddress
        "https://cache.nixos.org?priority=100"
      ];
      trusted-public-keys = [
        cfg.publicKey
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      connect-timeout = 3;
      stalled-download-timeout = 15;
      download-attempts = 2;

    };
  };
}
