{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.media;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
in
{
  options.local.media = {
    enable = lib.mkEnableOption "media server stack";

    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/media/Media";
      example = "/media/Media";
      description = "Base directory for media files";
    };

    jellyfin = {
      enable = lib.mkEnableOption "Jellyfin media server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8096;
        description = "HTTP port for Jellyfin";
      };

      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = urlHelpers.buildServiceUrl {
          port = config.local.media.jellyfin.port;
          subPath = "";
        };
        description = "Base URL for Jellyfin (auto-configured based on reverse proxy and Avahi settings)";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/jellyfin";
        description = "Data directory for Jellyfin";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Jellyfin";
      };

      subPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/jellyfin";
        description = "Subpath for reverse proxy (e.g., /jellyfin)";
      };
    };

    plex = {
      enable = lib.mkEnableOption "Plex Media Server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 32400;
        description = "HTTP port for Plex";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Plex";
      };
    };

    ersatztv = {
      enable = lib.mkEnableOption "ErsatzTV streaming service";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8409;
        description = "HTTP port for ErsatzTV";
      };

      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = urlHelpers.buildServiceUrl {
          port = config.local.media.ersatztv.port;
          subPath = "";
        };
        description = "Base URL for ErsatzTV (auto-configured based on reverse proxy and Avahi settings)";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/ersatztv";
        description = "Data directory for ErsatzTV";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for ErsatzTV";
      };

      subPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/ersatztv";
        description = "Subpath for reverse proxy (e.g., /ersatztv)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure media directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.mediaDir} 0777 tod users -"
      "d ${cfg.mediaDir}/movies 0777 tod users -"
      "d ${cfg.mediaDir}/tv 0777 tod users -"
      "d ${cfg.mediaDir}/music 0777 tod users -"
    ] ++ lib.optionals cfg.ersatztv.enable [
      "d ${cfg.ersatztv.dataDir} 0755 root root -"
    ] ++ lib.optionals (cfg.jellyfin.enable && cfg.jellyfin.subPath != "") [
      "d ${cfg.jellyfin.dataDir}/config 0755 jellyfin jellyfin -"
    ] ++ lib.optionals cfg.plex.enable [
      "d /var/lib/plex 0777 root root -"
    ];

    # Jellyfin
    services.jellyfin = lib.mkIf cfg.jellyfin.enable {
      enable = true;
      dataDir = cfg.jellyfin.dataDir;
      openFirewall = cfg.jellyfin.openFirewall;
    };

    # Plex
    services.plex = lib.mkIf cfg.plex.enable {
      enable = true;
      openFirewall = cfg.plex.openFirewall;
      user = "tod";
      group = "users";
    };

    # Write Jellyfin network configuration for reverse proxy
    environment.etc."jellyfin/network.xml" = lib.mkIf (cfg.jellyfin.enable && cfg.jellyfin.subPath != "") {
      text = ''<?xml version="1.0" encoding="utf-8"?>
        <NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
          <BaseUrl>${cfg.jellyfin.subPath}</BaseUrl>
        </NetworkConfiguration>
      '';
    };

    # Symlink config to Jellyfin data directory
    #systemd.services.jellyfin.preStart = lib.mkIf (cfg.jellyfin.enable && cfg.jellyfin.subPath != "") ''
    #  mkdir -p ${cfg.jellyfin.dataDir}/config
    #  ln -sf /etc/jellyfin/network.xml ${cfg.jellyfin.dataDir}/config/network.xml
    #'';

    # Write Jellyfin network configuration for reverse proxy
    virtualisation.oci-containers.containers.ersatztv = lib.mkIf cfg.ersatztv.enable {
      image = "jasongdove/ersatztv:latest";
      ports = [ "${toString cfg.ersatztv.port}:8409" ];
      volumes = [
        "${cfg.ersatztv.dataDir}:/root/.local/share/ersatztv"
        "${cfg.mediaDir}:/Media:ro"
      ];
      environment = {
        TZ = config.time.timeZone or "UTC";
      } // lib.optionalAttrs (cfg.ersatztv.subPath != "") {
        ETV_BASE_URL = cfg.ersatztv.subPath;
      };
      autoStart = true;
    };

    # Open firewall for ErsatzTV if needed
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.ersatztv.openFirewall [ cfg.ersatztv.port ];

    # Enable Docker/Podman if ErsatzTV is enabled
    virtualisation.oci-containers.backend = lib.mkIf cfg.ersatztv.enable "podman";
    virtualisation.podman = lib.mkIf cfg.ersatztv.enable {
      enable = true;
      dockerCompat = true;
    };
  };
}
