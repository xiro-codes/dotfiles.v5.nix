{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.download;
in
{
  options.local.download = {
    enable = lib.mkEnableOption "download services";

    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = "/media/Media/Downloads";
      example = "/mnt/storage/downloads";
      description = "Base directory for downloads";
    };

    transmission = {
      enable = lib.mkEnableOption "Transmission BitTorrent client";
      
      port = lib.mkOption {
        type = lib.types.port;
        default = 9091;
        description = "Web interface port";
      };

      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString config.local.download.transmission.port}";
        description = "Base URL for Transmission (auto-configured based on Avahi settings)";
      };

      peerPort = lib.mkOption {
        type = lib.types.port;
        default = 51413;
        description = "Port for incoming peer connections";
      };

      rpcWhitelist = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1,192.168.*.*,10.*.*.*";
        description = "Whitelist for RPC connections";
      };

      downloadDirPermissions = lib.mkOption {
        type = lib.types.str;
        default = "0775";
        description = "Permissions for download directory";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall ports for Transmission";
      };

      subPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/transmission";
        description = "Subpath for reverse proxy (e.g., /transmission)";
      };
    };

    pinchflat = {
      enable = lib.mkEnableOption "Pinchflat YouTube downloader";
      
      port = lib.mkOption {
        type = lib.types.port;
        default = 8945;
        description = "Web interface port";
      };

      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString config.local.download.pinchflat.port}";
        description = "Base URL for Pinchflat (auto-configured based on Avahi settings)";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/pinchflat";
        description = "Data directory for Pinchflat";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Pinchflat";
      };

      subPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/pinchflat";
        description = "Subpath for reverse proxy (e.g., /pinchflat)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure download directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.downloadDir} 0755 root root -"
      "d ${cfg.downloadDir}/torrents 0755 root root -"
      "d ${cfg.downloadDir}/youtube 0755 root root -"
    ] ++ lib.optionals cfg.pinchflat.enable [
      "d ${cfg.pinchflat.dataDir} 0755 root root -"
    ];

    # Transmission
    services.transmission = lib.mkIf cfg.transmission.enable {
      enable = true;
      
      settings = {
        download-dir = "${cfg.downloadDir}/torrents/complete";
        incomplete-dir = "${cfg.downloadDir}/torrents/incomplete";
        incomplete-dir-enabled = true;
        
        rpc-bind-address = "0.0.0.0";
        rpc-port = cfg.transmission.port;
        rpc-whitelist = cfg.transmission.rpcWhitelist;
        rpc-whitelist-enabled = true;
        rpc-authentication-required = false;
        rpc-url = if cfg.transmission.subPath != "" then cfg.transmission.subPath + "/" else "/transmission/";
        
        peer-port = cfg.transmission.peerPort;
        
        # Performance settings
        download-queue-enabled = true;
        download-queue-size = 5;
        peer-limit-global = 200;
        peer-limit-per-torrent = 50;
        
        # Privacy
        dht-enabled = true;
        lpd-enabled = true;
        pex-enabled = true;
        
        # Ratio
        ratio-limit-enabled = false;
      };

      openPeerPorts = cfg.transmission.openFirewall;
      openRPCPort = cfg.transmission.openFirewall;
    };

    # Pinchflat (using OCI container)
    virtualisation.oci-containers.containers.pinchflat = lib.mkIf cfg.pinchflat.enable {
      image = "ghcr.io/kieraneglin/pinchflat:latest";
      ports = [ "${toString cfg.pinchflat.port}:8945" ];
      volumes = [
        "${cfg.pinchflat.dataDir}:/config"
        "${cfg.downloadDir}/youtube:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone or "UTC";
        PUID = "1000";
        PGID = "1000";
      } // lib.optionalAttrs (cfg.pinchflat.subPath != "") {
        BASE_PATH = cfg.pinchflat.subPath;
      };
      autoStart = true;
    };

    # Open firewall for Pinchflat if needed
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.pinchflat.openFirewall [ cfg.pinchflat.port ];

    # Enable Podman if Pinchflat is enabled
    virtualisation.oci-containers.backend = lib.mkIf cfg.pinchflat.enable "podman";
    virtualisation.podman = lib.mkIf cfg.pinchflat.enable {
      enable = true;
      dockerCompat = true;
    };
  };
}
