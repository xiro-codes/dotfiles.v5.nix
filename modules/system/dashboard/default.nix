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
    subPath = "";
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

    subPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/dashboard";
      description = "Subpath for reverse proxy (e.g., /dashboard)";
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

        # Configure base path for reverse proxy
        base = lib.mkIf (cfg.subPath != "") cfg.subPath;
        layout = {
          Services = {
            style = "row";
            columns = 3;
          };
          Media = {
            style = "row";
            columns = 3;
          };
          System = {
            style = "row";
            columns = 2;
          };
        };
      };
      services =
        let
          # Check if reverse proxy is enabled to determine URL format
          useProxy = config.local.reverse-proxy.enable or false;

          # Helper to build service URL
          serviceUrl = path: port:
            if useProxy
            then "${baseUrl}${path}"
            else "${baseUrl}:${toString port}";

          # Build service list based on what's enabled
          servicesList = lib.flatten [
            # Services section
            (lib.optional (config.local.gitea.enable or false) {
              Gitea = {
                icon = "gitea.png";
                href = serviceUrl (config.local.gitea.subPath or "/gitea") (config.local.gitea.port or 3001);
                description = "Self-hosted Git service";
              };
            })
          ];

          mediaList = lib.flatten [
            (lib.optional (config.local.media.jellyfin.enable or false) {
              Jellyfin = {
                icon = "jellyfin.png";
                href = serviceUrl (config.local.media.jellyfin.subPath or "/jellyfin") (config.local.media.jellyfin.port or 8096);
                description = "Media server";
              };
            })
            (lib.optional (config.local.media.ersatztv.enable or false) {
              ErsatzTV = {
                icon = "ersatztv.png";
                href = serviceUrl (config.local.media.ersatztv.subPath or "/ersatztv") (config.local.media.ersatztv.port or 8409);
                description = "Live TV streaming";
              };
            })
          ];

          downloadList = lib.flatten [
            (lib.optional (config.local.download.transmission.enable or false) {
              Transmission = {
                icon = "transmission.png";
                href = serviceUrl (config.local.download.transmission.subPath or "/transmission") (config.local.download.transmission.port or 9091);
                description = "BitTorrent client";
              };
            })
            (lib.optional (config.local.download.pinchflat.enable or false) {
              Pinchflat = {
                icon = "pinchflat.png";
                href = serviceUrl (config.local.download.pinchflat.subPath or "/pinchflat") (config.local.download.pinchflat.port or 8945);
                description = "YouTube downloader";
              };
            })
            (lib.optional (config.local.download.qbittorrent.enable or false) {
              Qbittorrent = {
                icon = "qbittorrent.png";
                href = serviceUrl (config.local.download.qbittorrent.subPath or "/qbittorrent") (config.local.download.qbittorrent.port or 8080);
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
            disk = "/";
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
