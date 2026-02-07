{ ... }:
{
  local = {
    # Media services
    media = {
      enable = true;
      mediaDir = "/media/Media/";

      jellyfin = { enable = true; };
      plex = { enable = true; };
      ersatztv = { enable = true; };
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
