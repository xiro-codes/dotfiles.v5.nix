{
  config,
  lib,
  ...
}:
let
  inherit (lib) toLower;
in
{
  local = {
    # Reverse proxy with HTTPS
    reverse-proxy = {
      enable = true;
      # Domain auto-configured from Avahi: hostname.local
      useACME = false; # Self-signed for .local domains
      domain = "${toLower config.networking.hostName}.home";
      sharedFolders = {
        wallpapers = "/media/Media/wallpapers";
        games = "/media/Media/games";
        icons = "/media/Media/icons";
      };

      services = {
        dashboard.target = "http://localhost:${toString config.local.dashboard.port}";

        git.target = "http://localhost:${toString config.local.gitea.port}";

        tv.target = "http://localhost:${toString config.local.media.jellyfin.port}";

        ch7.target = "http://localhost:${toString config.local.media.ersatztv.port}";

        comics.target = "http://localhost:${toString config.local.media.komga.port}";
        audiobooks.target = "http://localhost:${toString config.local.media.audiobookshelf.port}";

        dl = {
          target = "http://localhost:${toString config.local.downloads.qbittorrent.port}";
          extraConfig = "client_max_body_size 1G;";
        };
        shoko.target = "http://localhost:${toString config.local.media.shoko-server.port}";
        yt.target = "http://localhost:${toString config.local.downloads.pinchflat.port}";

        stats.target = "http://localhost:${toString config.local.coolercontrol.port}";
        metrics.target = "http://localhost:${toString config.local.glances.port}";

        cache.target = "http://localhost:5000";
      };
    };
  };
}
