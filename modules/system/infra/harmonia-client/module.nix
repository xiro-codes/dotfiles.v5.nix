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
      default = "cache.sapphire.home-1:T6/FA9b6BgZvvvoXIzc4y/5MJgPs2GVHpi0KcU/fUMo=";
      example = "cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz==";
      description = "Public key for cache verification";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ];
    nix.settings = {
      post-build-hook =
        let
          uploadHook = pkgs.writeShellScript "upload-to-cache-hook" ''
            set -eu
            if [ -n "''${OUT_PATHS:-}" ]; then
              # shellcheck disable=SC2086
              ${lib.getExe' pkgs.systemd "systemd-run"} --unit="nix-upload-$(date +%s%N)" \
                --description="Upload Nix paths to cache" \
                --no-block \
                env NIX_SSHOPTS="-o StrictHostKeyChecking=accept-new" \
                ${getExe pkgs.nix} copy --to ssh-ng://build@${primaryIp} $OUT_PATHS
            fi
          '';
        in
        "${uploadHook}";
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
