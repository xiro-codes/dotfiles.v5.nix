{ config, lib, ... }:
{
  local = {
    pihole = {
      enable = true;
      adminPassword = "rockman";
    };

    file-browser = {
      enable = true;
      rootPath = "/media";
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

        files.target = "http://localhost:${toString config.local.file-browser.port}";

        tv.target = "http://localhost:${toString config.local.media.jellyfin.port}";
        plex.target = "http://localhost:${toString config.local.media.plex.port}";

        ch7.target = "http://localhost:${toString config.local.media.ersatztv.port}";

        dl.target = "http://localhost:${toString config.local.downloads.qbittorrent.port}";

        yt.target = "http://localhost:${toString config.local.downloads.pinchflat.port}";

        sonarr.target = "http://localhost:${toString config.local.downloads.sonarr.port}";
        prowlarr.target = "http://localhost:${toString config.local.downloads.prowlarr.port}";

        pihole.target = "http://localhost:8053";
      };
    };

    # Dashboard
    dashboard = {
      enable = true;
      allowedHosts = [ config.local.reverse-proxy.domain "localhost" ];
    };

    # Git service
    gitea = { enable = true; };
    gitea-runner = { enable = true; };

    # Media services
    media = {
      enable = true;
      # mediaDir = "/media/Media/";

      jellyfin = { enable = true; };
      plex = { enable = true; };

      ersatztv = { enable = true; };
    };

    # Download services
    downloads = {
      enable = true;
      # downloadDir = "/media/Media/downloads";

      qbittorrent = { enable = true; };
      pinchflat = { enable = true; };
      sonarr = { enable = true; };
      prowlarr = { enable = true; };
    };

    file-sharing = {
      enable = true;
      shareDir = "/media/";
      nfs.enable = true;
      samba.enable = true;

      definitions = {
        media = {
          path = "${config.local.media.mediaDir}";
          comment = "Media files";
          guestOk = true;
          validUsers = [ "tod" ];
        };
        music = {
          path = "${config.local.media.mediaDir}/music";
          comment = "Music files";
          guestOk = true;
          validUsers = [ "tod" ];
        };
        backups = {
          path = "/media/Backups";
          comment = "Backup directory";
          guestOk = true;
          validUsers = [ "tod" ];
        };
      };
    };
  };
}
