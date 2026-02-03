{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.dashboard;
  hostsCfg = config.local.hosts;
  
  # Helper to get current host address
  currentAddress = 
    if hostsCfg.useAvahi
    then "${config.networking.hostName}.local"
    else if builtins.hasAttr config.networking.hostName hostsCfg
         then hostsCfg.${config.networking.hostName}
         else config.networking.hostName;
  
  # Current host base URL
  baseUrl = "http://${currentAddress}";
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
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = cfg.port;
      
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
          System = {
            style = "row";
            columns = 2;
          };
        };
      };

      services = [
        {
          Services = [
            {
              Gitea = {
                icon = "gitea.png";
                href = "${baseUrl}:3001";
                description = "Self-hosted Git service";
              };
            }
            {
              "Nix Cache" = {
                icon = "nix.png";
                href = "${baseUrl}:8080";
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
                href = "${baseUrl}:8096";
                description = "Media server";
              };
            }
            {
              Plex = {
                icon = "plex.png";
                href = "${baseUrl}:32400";
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
  };
}
