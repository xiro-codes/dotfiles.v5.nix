{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.media;
in
{
  options.local.media = {
    enable = lib.mkEnableOption "media server stack";

    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/media";
      example = "/mnt/storage/media";
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
        default = "http://localhost:${toString config.local.media.jellyfin.port}";
        description = "Base URL for Jellyfin (auto-configured based on Avahi settings)";
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
      enable = lib.mkEnableOption "Plex media server";
      
      port = lib.mkOption {
        type = lib.types.port;
        default = 32400;
        description = "HTTP port for Plex";
      };

      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString config.local.media.plex.port}";
        description = "Base URL for Plex (auto-configured based on Avahi settings)";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/plex";
        description = "Data directory for Plex";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Plex";
      };

      subPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/plex";
        description = "Subpath for reverse proxy (e.g., /plex). Note: Plex has limited subpath support.";
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
        default = "http://localhost:${toString config.local.media.ersatztv.port}";
        description = "Base URL for ErsatzTV (auto-configured based on Avahi settings)";
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
      "d ${cfg.mediaDir} 0755 root root -"
      "d ${cfg.mediaDir}/movies 0755 root root -"
      "d ${cfg.mediaDir}/tv 0755 root root -"
      "d ${cfg.mediaDir}/music 0755 root root -"
    ] ++ lib.optionals cfg.ersatztv.enable [
      "d ${cfg.ersatztv.dataDir} 0755 root root -"
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
      dataDir = cfg.plex.dataDir;
      openFirewall = cfg.plex.openFirewall;
    };

    # ErsatzTV (using virtualisation.oci-containers since there's no native NixOS module)
    virtualisation.oci-containers.containers.ersatztv = lib.mkIf cfg.ersatztv.enable {
      image = "jasongdove/ersatztv:latest";
      ports = [ "${toString cfg.ersatztv.port}:8409" ];
      volumes = [
        "${cfg.ersatztv.dataDir}:/root/.local/share/ersatztv"
        "${cfg.mediaDir}:/media:ro"
      ];
      environment = {
        TZ = config.time.timeZone or "UTC";
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
