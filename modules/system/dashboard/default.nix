{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.dashboard;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };

  # Base URL for service links
  baseUrl = urlHelpers.buildServiceUrl {
    port = cfg.port;
  };

  # Auto-configure allowed hosts
  autoAllowedHosts = urlHelpers.getAllowedHosts;
in
{
  options.local.dashboard = {
    enable = lib.mkEnableOption "homepage dashboard";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port to run the dashboard on";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall port for dashboard";
    };


    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = autoAllowedHosts;
      example = [ "onix.local" "192.168.1.100" ];
      description = "List of allowed hostnames for accessing the dashboard (for reverse proxy). Defaults to hostname, IP, and .local address.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = cfg.port;
      allowedHosts = lib.concatStringsSep "," cfg.allowedHosts;

      settings = {
        title = "Home Server Dashboard";

        layout = {
          Services = {
            style = "row";
            columns = 3;
          };
          Media = {
            style = "row";
            columns = 3;
          };
          Downloads = {
            style = "row";
            columns = 3;
          };
        };
      };
      services =
        let
          # Check if reverse proxy is enabled to determine URL format
          useProxy = config.local.reverse-proxy.enable or false;
          domain = config.local.reverse-proxy.domain or "onix.local";
          # Helper to build service URL
          serviceUrl = name: port:
            if useProxy
            then "http://${name}.${domain}"
            else "http://${domain}:${toString port}";

          # Build service list based on what's enabled
          servicesList = lib.flatten [
            # Documentation
            (lib.optional (config.local.docs.enable or false) {
              Docs = {
                icon = "mdi-book-information";
                href = serviceUrl "docs" (config.services.docs.port or 3001);
                description = "Dotfiles Documentation";
              };
            })

            # Services section
            (lib.optional (config.local.file-browser.enable or false) {
              Files = {
                icon = "filebrowser.png";
                href = serviceUrl "files" (config.local.file-browser.port or 8082);
                description = "Web File Browser";
              };
            })
            (lib.optional (config.local.gitea.enable or false) {
              Gitea = {
                icon = "gitea.png";
                href = serviceUrl "git" (config.local.gitea.port or 3001);
                description = "Self-hosted Git service";
              };
            })
            (lib.optional (config.local.pihole.enable or false) {
              PiHole = {
                icon = "pi-hole.png";
                href = "${serviceUrl "pihole" 8053}/admin";
                description = "AdBlocking and Local dns";
              };
            })
            (lib.optional (config.local.media.ersatztv.enable or false) {
              ErsatzTV = {
                icon = "ersatztv.png";
                href = serviceUrl "ch7" (config.local.media.ersatztv.port or 8409);
                description = "Live TV streaming";
              };
            })
          ];

          mediaList = lib.flatten [
            (lib.optional (config.local.media.jellyfin.enable or false) {
              Jellyfin = {
                icon = "jellyfin.png";
                href = serviceUrl "tv" (config.local.media.jellyfin.port or 8096);
                description = "Media server";
              };
            })
            (lib.optional (config.local.media.plex.enable or false) {
              Plex = {
                icon = "plex.png";
                href = serviceUrl "plex" (config.local.media.plex.port or 32400);
                description = "Media server";
              };
            })
            (lib.optional (config.local.media.komga.enable or false) {
              Komga = {
                icon = "komga.png";
                href = serviceUrl "comics" (config.local.media.komga.port or 8080);
                description = "Comic/manga server";
              };
            })
            (lib.optional (config.local.media.audiobookshelf.enable or false) {
              Audiobookshelf = {
                icon = "audiobookshelf.png";
                href = serviceUrl "audiobooks" (config.local.media.audiobookshelf.port or 13378);
                description = "Audiobook server";
              };
            })
          ];

          downloadList = lib.flatten [
            (lib.optional (config.local.downloads.pinchflat.enable or false) {
              Pinchflat = {
                icon = "pinchflat.png";
                href = serviceUrl "yt" (config.local.downloads.pinchflat.port or 8945);
                description = "YouTube downloader";
              };
            })
            (lib.optional (config.local.downloads.qbittorrent.enable or false) {
              Qbittorrent = {
                icon = "qbittorrent.png";
                href = serviceUrl "dl" (config.local.downloads.qbittorrent.port or 8080);
                description = "BitTorrent client";
              };
            })
          ];
        in
        lib.filter (x: x != { }) [
          (lib.mkIf (servicesList != [ ]) { Services = servicesList; })
          (lib.mkIf (mediaList != [ ]) { Media = mediaList; })
          (lib.mkIf (downloadList != [ ]) { Downloads = downloadList; })
        ];

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = [ "/" "/media/Media" "/media/Backups" ];
          };
        }
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # Configure homepage to accept proxied requests
    systemd.services.homepage-dashboard = lib.mkIf (cfg.allowedHosts != [ ]) {
      environment = {
        #HOMEPAGE_CONFIG_ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
        #HOMEPAGE_ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
      };
    };
  };
}
