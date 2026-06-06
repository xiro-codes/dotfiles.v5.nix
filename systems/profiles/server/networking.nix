{
  config,
  lib,
  ...
}:
let
  inherit (lib.strings) toLower;
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
        files = "/media/Media/games";
        wallpapers = "/media/Media/wallpapers";
        games = "/media/Media/games";
      };

      services = {
        dashboard.target = "http://localhost:${toString config.local.dashboard.port}";

        git.target = "http://localhost:${toString config.local.gitea.port}";

        # Media servers (nixarr defaults)
        tv.target = "http://localhost:8096"; # Jellyfin
        plex.target = "http://localhost:32400";

        comics.target = "http://localhost:25600"; # Komga
        audiobooks.target = "http://localhost:13378"; # Audiobookshelf

        # Download client (nixarr qBittorrent default)
        dl.target = "http://localhost:5252";

        # *Arr services
        sonarr.target = "http://localhost:8989";
        radarr.target = "http://localhost:7878";
        lidarr.target = "http://localhost:8686";
        prowlarr.target = "http://localhost:9696";
        bazarr.target = "http://localhost:6767";

        # files.target = "http://localhost:${toString config.local.file-browser.port}";
        cache.target = "http://localhost:5000";
      };
    };
  };
}
