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
    name = "13054947.png";
    path = fetchWallpaper {
      name = "13054947.png";
      url = "https://wallpapers.sapphire.home/13054947.png";
      sha256 = "sha256-hmMAFWQBfZS96r/QiCGvYCXXvKbtCwodql+WTMVglZI=";
    };
  }
  {
    name = "20482113.jpg";
    path = fetchWallpaper {
      name = "20482113.jpg";
      url = "https://wallpapers.sapphire.home/20482113.jpg";
      sha256 = "sha256-i/lEHzopdSrn4FWjw3aIzUFUWQsOlcEHGMSht6CwlbA=";
    };
  }
  {
    name = "360j6wxeh7zf1.jpeg";
    path = fetchWallpaper {
      name = "360j6wxeh7zf1.jpeg";
      url = "https://wallpapers.sapphire.home/360j6wxeh7zf1.jpeg";
      sha256 = "sha256-Lp6CAHJc+rJEWDo3z9DtH/J543zdJth079M3nMW1OwM=";
    };
  }
  {
    name = "classy.jpg";
    path = fetchWallpaper {
      name = "classy.jpg";
      url = "https://wallpapers.sapphire.home/classy.jpg";
      sha256 = "sha256-3iCuQcKW/7xz0cgLOKMxU0Nq6l02wCsCUu0nSV0f9UI=";
    };
  }
  {
    name = "fpk3jfrhmojg1.jpeg";
    path = fetchWallpaper {
      name = "fpk3jfrhmojg1.jpeg";
      url = "https://wallpapers.sapphire.home/fpk3jfrhmojg1.jpeg";
      sha256 = "sha256-+te4gHGwIFKX6nxYYF4esyZQSWlAI6FKdr/MZWPIjuk=";
    };
  }
  {
    name = "gruvbox.jpg";
    path = fetchWallpaper {
      name = "gruvbox.jpg";
      url = "https://wallpapers.sapphire.home/gruvbox.jpg";
      sha256 = "sha256-IFHXILEFHefH8jvYy334ERze7Wn4AsybeWxgekOKaOM=";
    };
  }
  {
    name = "metafor.jpg";
    path = fetchWallpaper {
      name = "metafor.jpg";
      url = "https://wallpapers.sapphire.home/metafor.jpg";
      sha256 = "sha256-DNXaKG61TSyu5DeWVCyKmBBL1h/kF+tHjUseVY9Wl+o=";
    };
  }
  {
    name = "miku.jpeg";
    path = fetchWallpaper {
      name = "miku.jpeg";
      url = "https://wallpapers.sapphire.home/miku.jpeg";
      sha256 = "sha256-Lp6CAHJc+rJEWDo3z9DtH/J543zdJth079M3nMW1OwM=";
    };
  }
  {
    name = "raiden.png";
    path = fetchWallpaper {
      name = "raiden.png";
      url = "https://wallpapers.sapphire.home/raiden.png";
      sha256 = "sha256-GntA5UcMuua2z7/JXGR2p2fZCUXzhl9WJFP66Oj9dVA=";
    };
  }
  {
    name = "red-demon-girl.png";
    path = fetchWallpaper {
      name = "red-demon-girl.png";
      url = "https://wallpapers.sapphire.home/red-demon-girl.png";
      sha256 = "sha256-H5xkLMsRi/01VkMPQN+P6HuwO1HtyQDSxKWSadGEg1M=";
    };
  }
  {
    name = "room.png";
    path = fetchWallpaper {
      name = "room.png";
      url = "https://wallpapers.sapphire.home/room.png";
      sha256 = "sha256-dOtbav0HQy1iex/I1oaeYj3i6LCa9alE8d9U2KTuD9s=";
    };
  }
  {
    name = "showdown.png";
    path = fetchWallpaper {
      name = "showdown.png";
      url = "https://wallpapers.sapphire.home/showdown.png";
      sha256 = "sha256-AWT3mBl8XcPWveXyhbKIFxnJAIFMt2D7vHY3l3gkM8g=";
    };
  }
  {
    name = "spacefold.jpg";
    path = fetchWallpaper {
      name = "spacefold.jpg";
      url = "https://wallpapers.sapphire.home/spacefold.jpg";
      sha256 = "sha256-82U7OdPePhwXBI8jAaHrxprM9VARv1az+1lbz97b4lM=";
    };
  }
  {
    name = "violet.jpg";
    path = fetchWallpaper {
      name = "violet.jpg";
      url = "https://wallpapers.sapphire.home/violet.jpg";
      sha256 = "sha256-IfTC7BEGYwwi6RwskUL53FUVtrpgMAlW3iJqoGmENjQ=";
    };
  }
  {
    name = "wallpaper-02-Kentucky-Route-Zero.jpg";
    path = fetchWallpaper {
      name = "wallpaper-02-Kentucky-Route-Zero.jpg";
      url = "https://wallpapers.sapphire.home/wallpaper-02-Kentucky-Route-Zero.jpg";
      sha256 = "sha256-X6DvVImOWwtABxwwP3gsnWpcyomQPUTU2kMR+oLv+hc=";
    };
  }

  # ── Deskmat ──────────────────────────────────────────────────────
  {
    name = "deskmat-1.jpg";
    path = fetchWallpaper {
      name = "deskmat-1.jpg";
      url = "https://wallpapers.sapphire.home/Deskmat/1.jpg";
      sha256 = "sha256-MDIjJVlhXCLgCMsc9aGEx8A09hgJasjjvWdTTrTVL5c=";
    };
  }
  {
    name = "deskmat-2.jpg";
    path = fetchWallpaper {
      name = "deskmat-2.jpg";
      url = "https://wallpapers.sapphire.home/Deskmat/2.jpg";
      sha256 = "sha256-tTo3IwJMansdNaFJvMAWYMcFtrHqPx3fY7ixpA4hv+A=";
    };
  }
  {
    name = "deskmat-3.jpg";
    path = fetchWallpaper {
      name = "deskmat-3.jpg";
      url = "https://wallpapers.sapphire.home/Deskmat/3.jpg";
      sha256 = "sha256-njgmz8cGbLYkN8aLTmkrYIMGbtQTMX72ttecLQ+oSVE=";
    };
  }
  {
    name = "deskmat-4.jpg";
    path = fetchWallpaper {
      name = "deskmat-4.jpg";
      url = "https://wallpapers.sapphire.home/Deskmat/4.jpg";
      sha256 = "sha256-nRymGfCwYj4oyKWck6trSg/gTZiKWZFY0eyFnVrocx4=";
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
