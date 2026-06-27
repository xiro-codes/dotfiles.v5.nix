{
  pkgs,
  lib,
  ...
}:
let
  manifest = builtins.fromJSON (builtins.readFile ./manifest.json);
  sanitize = builtins.replaceStrings [" " "%20" "(" ")"] ["_" "_" "_" "_"];

  fetchAsset = item: {
    name = sanitize item.name;
    path = pkgs.fetchurl {
      name = sanitize (builtins.baseNameOf item.name);
      inherit (item) url sha256;
      curlOptsList = [
        "-X"
        "GET"
        "--insecure"
      ];
    };
  };
in
pkgs.linkFarm "icons" (map fetchAsset manifest)
