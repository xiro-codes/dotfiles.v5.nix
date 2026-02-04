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
        in
        [
          {
            Services = [
              {
                Gitea = {
                  icon = "gitea.png";
                  href = serviceUrl "/gitea" 3001;
                  description = "Self-hosted Git service";
                };
              }
              {
                "Nix Cache" = {
                  icon = "nix.png";
                  href = serviceUrl "/cache" 8080;
                  description = "Binary cache server";
                };
              }
            ];
          }
        {
          Media = [
            {
              Jellyfin = {
                icon = "jellyfin.png";
                href = serviceUrl "/jellyfin" 8096;
                description = "Media server";
              };
            }
          ];
        }
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
