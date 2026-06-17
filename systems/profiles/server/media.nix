{ config, ... }:
{
  local = {
    # Old media/downloads modules disabled — replaced by nixarr-stack
    media.enable = true;
    media.jellyfin.enable = true;
    media.komga.enable = true;
    media.audiobookshelf.enable = true;
    downloads.enable = true;
    downloads.qbittorrent.enable = true;
    # New nixarr-based media stack
    nixarr-stack = {
      enable = false;
      mediaDir = "/media/Media";
      vpn.enable = true;
    };

    gog-downloader = {
      enable = true;
      directory = "/media/Media/games";
      secretFile = config.sops.secrets."gog_creds".path;
    };
  };
}
