{ config, ... }:
{
  local = {
    # Old media/downloads modules disabled — replaced by nixarr-stack
    media = {
      enable = true;
      jellyfin = {
        enable = true;
        openFirewall = true;
      };
      ersatztv.enable = true;
      komga.enable = true;
      audiobookshelf.enable = true;
    };

    downloads = {
      enable = true;
      qbittorrent.enable = true;
    };

    gog-downloader = {
      enable = true;
      directory = "/media/Media/games";
    };
  };
}
