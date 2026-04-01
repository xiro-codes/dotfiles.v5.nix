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
        theme = "dark";
        color = "emerald";

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
          useProxy = config.local.reverse-proxy.enable;
          domain = config.local.reverse-proxy.domain;
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
            (optional (config.local.docs.enable) {
              Docs = {
                icon = "mdi-book-information";
                href = serviceUrl "docs" config.local.docs.port;
                description = "Dotfiles Documentation";
              };
            })

            # Services section
            [
              {
                "Open WebUI" = {
                  icon = "mdi-brain";
                  href = "http://ui.sapphire.home";
                  description = "LLM Interface on Sapphire";
                  siteMonitor = "http://ui.sapphire.home";
                };
              }
              {
                "VMs" = {
                  icon = "mdi-server";
                  href = "http://vm.onix.home";
                  description = "Incus Virtual Machines";
                  siteMonitor = "http://vm.onix.home";
                };
              }
            ]
            (optional (config.local.gitea.enable) {
              Gitea = {
                icon = "gitea.png";
                href = serviceUrl "git" config.local.gitea.port;
                description = "Self-hosted Git service";
              };
            })
            (optional (config.local.pihole.enable) {
              PiHole = {
                icon = "pi-hole.png";
                href = "${serviceUrl "pihole" 8053}/admin";
                description = "AdBlocking and Local dns";
              };
            })
            (optional (config.local.media.ersatztv.enable) {
              ErsatzTV = {
                icon = "ersatztv.png";
                href = serviceUrl "ch7" config.local.media.ersatztv.port;
                description = "Live TV streaming";
              };
            })
          ];

          mediaList = flatten [
            (optional (config.local.media.jellyfin.enable) {
              Jellyfin = {
                icon = "jellyfin.png";
                href = serviceUrl "tv" config.local.media.jellyfin.port;
                description = "Media server";
              };
            })
            (optional (config.local.media.plex.enable) {
              Plex = {
                icon = "plex.png";
                href = serviceUrl "plex" config.local.media.plex.port;
                description = "Media server";
              };
            })
            (optional (config.local.media.komga.enable) {
              Komga = {
                icon = "komga.png";
                href = serviceUrl "comics" config.local.media.komga.port;
                description = "Comic/manga server";
              };
            })
            (optional (config.local.media.audiobookshelf.enable) {
              Audiobookshelf = {
                icon = "audiobookshelf.png";
                href = serviceUrl "audiobooks" config.local.media.audiobookshelf.port;
                description = "Audiobook server";
              };
            })
          ];

          downloadList = flatten [
            (optional (config.local.downloads.pinchflat.enable) {
              Pinchflat = {
                icon = "pinchflat.png";
                href = serviceUrl "yt" config.local.downloads.pinchflat.port;
                description = "YouTube downloader";
              };
            })
            (optional (config.local.downloads.qbittorrent.enable) {
              Qbittorrent = {
                icon = "qbittorrent.png";
                href = serviceUrl "dl" config.local.downloads.qbittorrent.port;
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
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
        {
          datetime = {
            text_size = "xl";
            format = {
              timeStyle = "short";
              dateStyle = "short";
            };
          };
        }
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
