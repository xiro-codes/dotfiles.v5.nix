{ config, lib, ... }:
{
  local = {
    pihole = {
      enable = true;
      adminPassword = "rockman";
    };

    # Reverse proxy with HTTPS
    reverse-proxy = {
      enable = true;
      # Domain auto-configured from Avahi: hostname.local
      useACME = false; # Self-signed for .local domains
      domain = "${lib.strings.toLower config.networking.hostName}.home";
      services = {
        dashboard.target = "http://localhost:${toString config.local.dashboard.port}";

        git.target = "http://localhost:${toString config.local.gitea.port}";


        tv.target = "http://localhost:${toString config.local.media.jellyfin.port}";
        plex.target = "http://localhost:${toString config.local.media.plex.port}";

        ch7.target = "http://localhost:${toString config.local.media.ersatztv.port}";

        comics.target = "http://localhost:${toString config.local.media.komga.port}";
        audiobooks.target = "http://localhost:${toString config.local.media.audiobookshelf.port}";

        dl.target = "http://localhost:${toString config.local.downloads.qbittorrent.port}";

        yt.target = "http://localhost:${toString config.local.downloads.pinchflat.port}";

        pihole.target = "http://localhost:8053";
        files.target = "http://localhost:${toString config.local.file-browser.port}";
      };
    };
  };
}
