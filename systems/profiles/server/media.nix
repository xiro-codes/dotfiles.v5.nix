{ ... }:
{
  local = {
    # Media services
    media = {
      enable = true;
      mediaDir = "/media/Media/";

      jellyfin.enable = false;
      plex.enable = true;
      plex.openFirewall = true;
      ersatztv.enable = false;
      audiobookshelf.enable = true;
      komga.enable = true;
    };

    # Download services
    downloads = {
      enable = true;
      downloadDir = "/media/Media/downloads";

      qbittorrent.enable = true;
      pinchflat.enable = true;
    };
  };
}
