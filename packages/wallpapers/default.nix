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
  {
    name = "miku.jpeg";
    path = fetchWallpaper {
      name = "miku.jpeg";
      url = "https://wallpapers.onix.home/miku.jpeg";
      sha256 = "sha256-Lp6CAHJc+rJEWDo3z9DtH/J543zdJth079M3nMW1OwM=";
    };
  }
  {
    name = "deskmat-1.jpg";
    path = fetchWallpaper {
      name = "deskmat-1.jpg";
      url = "https://wallpapers.onix.home/Deskmat/1.jpg";
      sha256 = "sha256-MDIjJVlhXCLgCMsc9aGEx8A09hgJasjjvWdTTrTVL5c=";
    };
  }
  {
    name = "disco.png";
    path = fetchWallpaper {
      name = "disco.png";
      url = "https://wallpapers.onix.home/Icons/disco.png";
      sha256 = "sha256-hy1iIDdnPY6ZPM5EYRbh66yFl7CUgLjbQubuGUvRErw=";
    };
  }
]
