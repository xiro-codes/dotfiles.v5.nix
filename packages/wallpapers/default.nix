{
  pkgs,
  lib,
  ...
}:
let
  fetchWallpaper =
    {
      name,
      url,
      sha256,
    }:
    pkgs.fetchurl {
      inherit name url sha256;
      curlOptsList = [
        "-X"
        "GET"
        "--insecure"
      ];
    };
in
pkgs.linkFarm "wallpapers" [
  # ── Root wallpapers ──────────────────────────────────────────────
  {
    name = "AG1.png";
    path = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;
  }
  # ── Icons ────────────────────────────────────────────────────────
  /*
  {
    name = "icons-disco.png";
    path = fetchWallpaper {
      name = "icons-disco.png";
      url = "https://wallpapers.sapphire.home/Icons/disco.png";
      sha256 = "sha256-hy1iIDdnPY6ZPM5EYRbh66yFl7CUgLjbQubuGUvRErw=";
    };
  }
  */
]
