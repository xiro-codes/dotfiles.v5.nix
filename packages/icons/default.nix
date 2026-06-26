{
  pkgs,
  lib,
  ...
}:
let
  manifest = builtins.fromJSON (builtins.readFile ./manifest.json);
  
  fetchAsset = item: {
    name = item.name;
    path = pkgs.fetchurl {
      inherit (item) name url sha256;
      curlOptsList = [
        "-X"
        "GET"
        "--insecure"
      ];
    };
  };
in
pkgs.linkFarm "icons" (map fetchAsset manifest)
