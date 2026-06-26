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
    path = fetchWallpaper {
      name = "13054947.png";
      url = "https://wallpapers.sapphire.home/ag_1.png";
      sha256 = "sha256-hmMAFWQBfZS96r/QiCGvYCXXvKbtCwodql+WTMVglZI=";
    };
  }
  # ── Icons ────────────────────────────────────────────────────────
  {
    name = "icons-disco.png";
    path = fetchWallpaper {
      name = "icons-disco.png";
      url = "https://wallpapers.sapphire.home/Icons/disco.png";
      sha256 = "sha256-hy1iIDdnPY6ZPM5EYRbh66yFl7CUgLjbQubuGUvRErw=";
    };
  }
]
