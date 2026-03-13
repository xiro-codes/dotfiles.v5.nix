{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib) concatStringsSep filter flatten mapAttrsToList mkEnableOption mkIf mkOption optional types;

  cfg = config.local.dashboard;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };

  # Base URL for service links
  baseUrl = urlHelpers.buildServiceUrl {
    port = cfg.port;
  };

  # Auto-configure allowed hosts
  autoAllowedHosts = urlHelpers.getAllowedHosts;
  proxyCfg = config.local.reverse-proxy;
in
{
  options.local.dashboard = {
    enable = mkEnableOption "homepage dashboard";

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port to run the dashboard on";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall port for dashboard";
    };


    allowedHosts = mkOption {
      type = types.listOf types.str;
      default = autoAllowedHosts;
      example = [ "onix.local" "192.168.1.100" ];
      description = "List of allowed hostnames for accessing the dashboard (for reverse proxy). Defaults to hostname, IP, and .local address.";
    };
  };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = cfg.port;
      allowedHosts = concatStringsSep "," cfg.allowedHosts;

      settings = {
        title = "Home Server Dashboard";

        layout = {
          Services = {
            style = "row";
            columns = 3;
          };
          "Shared Folders" = { style = "row"; columns = 3; };
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

          sharedFoldersList = mapAttrsToList
            (subdomain: path: {
              "${subdomain}" = {
                icon = "mdi-folder-network";
                href = if useProxy then "http://${subdomain}.${domain}" else "#";
                description = "Static files from ${path}";
              };
            })
            (proxyCfg.sharedFolders or { });

          # Build service list based on what's enabled
          servicesList = flatten [
            # Documentation
            (optional (config.local.docs.enable or false) {
              Docs = {
                icon = "mdi-book-information";
                href = serviceUrl "docs" (config.services.docs.port or 3001);
                description = "Dotfiles Documentation";
              };
            })

            # Services section
            (optional (config.local.gitea.enable or false) {
              Gitea = {
                icon = "gitea.png";
                href = serviceUrl "git" (config.local.gitea.port or 3001);
                description = "Self-hosted Git service";
              };
            })
            (optional (config.local.pihole.enable or false) {
              PiHole = {
                icon = "pi-hole.png";
                href = "${serviceUrl "pihole" 8053}/admin";
                description = "AdBlocking and Local dns";
              };
            })
            (optional (config.local.media.ersatztv.enable or false) {
              ErsatzTV = {
                icon = "ersatztv.png";
                href = serviceUrl "ch7" (config.local.media.ersatztv.port or 8409);
                description = "Live TV streaming";
              };
            })
          ];

          mediaList = flatten [
            (optional (config.local.media.jellyfin.enable or false) {
              Jellyfin = {
                icon = "jellyfin.png";
                href = serviceUrl "tv" (config.local.media.jellyfin.port or 8096);
                description = "Media server";
              };
            })
            (optional (config.local.media.plex.enable or false) {
              Plex = {
                icon = "plex.png";
                href = serviceUrl "plex" (config.local.media.plex.port or 32400);
                description = "Media server";
              };
            })
            (optional (config.local.media.komga.enable or false) {
              Komga = {
                icon = "komga.png";
                href = serviceUrl "comics" (config.local.media.komga.port or 8080);
                description = "Comic/manga server";
              };
            })
            (optional (config.local.media.audiobookshelf.enable or false) {
              Audiobookshelf = {
                icon = "audiobookshelf.png";
                href = serviceUrl "audiobooks" (config.local.media.audiobookshelf.port or 13378);
                description = "Audiobook server";
              };
            })
          ];

          downloadList = flatten [
            (optional (config.local.downloads.pinchflat.enable or false) {
              Pinchflat = {
                icon = "pinchflat.png";
                href = serviceUrl "yt" (config.local.downloads.pinchflat.port or 8945);
                description = "YouTube downloader";
              };
            })
            (optional (config.local.downloads.qbittorrent.enable or false) {
              Qbittorrent = {
                icon = "qbittorrent.png";
                href = serviceUrl "dl" (config.local.downloads.qbittorrent.port or 8080);
                description = "BitTorrent client";
              };
            })
          ];
        in
        filter (x: x != { }) [
          (mkIf (servicesList != [ ]) { Services = servicesList; })
          (mkIf (sharedFoldersList != [ ]) { "Shared Folders" = sharedFoldersList; })
          (mkIf (mediaList != [ ]) { Media = mediaList; })
          (mkIf (downloadList != [ ]) { Downloads = downloadList; })
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

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    # Configure homepage to accept proxied requests
    systemd.services.homepage-dashboard = mkIf (cfg.allowedHosts != [ ]) {
      environment = {
        #HOMEPAGE_CONFIG_ALLOWED_HOSTS = concatStringsSep "," cfg.allowedHosts;
        #HOMEPAGE_ALLOWED_HOSTS = concatStringsSep "," cfg.allowedHosts;
      };
    };
  };
}
