{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.cache;
  uploadScript = pkgs.writeShellScript "upload-to-onix" ''
    set -eu
    # $OUT_PATHS contains a space-separated list of store paths just built
    if [ -n "$OUT_PATHS" ]; then
      echo "Uploading to Onix cache: $OUT_PATHS"
      # Use -i to specify the path to an SSH key if needed
      ${pkgs.nix}/bin/nix copy --to ssh://root@onix.local $OUT_PATHS
    fi
  '';
in
{
  options.local.cache = {
    enable = lib.mkEnableOption "cache module";
    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "http://10.0.0.65:5000/?priority=1";
      example = "http://cache.example.com:8080/nixos?priority=10";
      description = "Attic binary cache server URL with optional priority parameter";
    };
    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "cache.onix.home-1:/M1y/hGaD/dB8+mDfZmMdtXaWjq7XtLc1GMycddoNIE=";
      example = "cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz==";
      description = "Public key for cache verification";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ];
    nix.settings = {
      post-build-hook = "${uploadScript}";
      trusted-users = [ "@wheel" ];
      substituters = [
        cfg.serverAddress
        "https://cache.nixos.org?priority=100"
      ];
      trusted-public-keys = [
        cfg.publicKey
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };
}
