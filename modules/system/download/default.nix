{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.download;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
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
    qbittorrent = {
      enable = lib.mkEnableOption "Transmission BitTorrent client";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Web interface port";
      };


      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall ports for Transmission";
      };

      subPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/qbittorrent";
        description = "Subpath for reverse proxy (e.g., /transmission)";
      };
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
        default = urlHelpers.buildServiceUrl {
          port = config.local.download.transmission.port;
          subPath = "";
        };
        description = "Base URL for Transmission (auto-configured based on reverse proxy and Avahi settings)";
      };

      peerPort = lib.mkOption {
        type = lib.types.port;
        default = 51413;
        description = "Port for incoming peer connections";
      };

      rpcWhitelist = lib.mkOption {
        type = lib.types.str;
        default = "onix.local,127.0.0.1,192.168.*.*,10.*.*.*";
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
        default = urlHelpers.buildServiceUrl {
          port = config.local.download.pinchflat.port;
          subPath = "";
        };
        description = "Base URL for Pinchflat (auto-configured based on reverse proxy and Avahi settings)";
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
      "d ${cfg.downloadDir} 0755 root root -"
      "d ${cfg.downloadDir}/../youtube 0755 root root -"
    ] ++ lib.optionals cfg.pinchflat.enable [
      "d ${cfg.pinchflat.dataDir} 0755 root root -"
    ] ++ lib.optionals cfg.qbittorrent.enable [
      "d /var/lib/qbittorrent/config 0755 root root -"
    ];
    # 1. Create the "Real" Folder and Copy Files
    systemd.services.init-qbittorrent-config = lib.mkIf cfg.qbittorrent.enable {
      description = "Initialize qBittorrent config for passwordless access";
      before = [ "podman-qbittorrent.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        CONF_DIR="/var/lib/qbittorrent/config/qBittorrent"
        CONF_FILE="$CONF_DIR/qBittorrent.conf"
        mkdir -p "$CONF_DIR"

        if [ ! -f "$CONF_FILE" ]; then
          echo "[Preferences]" > "$CONF_FILE"
        fi

        # Use sed to ensure the whitelist is enabled and set to allow all
        # This removes the password requirement for all IP ranges
        sed -i '/WebUI\\AuthSubnetWhitelistEnabled=/d' "$CONF_FILE"
        sed -i '/WebUI\\AuthSubnetWhitelist=/d' "$CONF_FILE"
        sed -i '/\[Preferences\]/a WebUI\\AuthSubnetWhitelistEnabled=true\nWebUI\\AuthSubnetWhitelist=0.0.0.0/0' "$CONF_FILE"
        
        # Ensure correct permissions for the container user
        chown -R 1000:100 "$CONF_DIR/.."
      '';
    };
    virtualisation.oci-containers.containers.qbittorrent = lib.mkIf cfg.qbittorrent.enable {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      ports = [
        "${toString cfg.qbittorrent.port}:8080" # WebUI
        "6881:6881" # BitTorrent TCP
        "6881:6881/udp" # BitTorrent UDP
      ];
      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "${cfg.downloadDir}:/downloads"
      ];
      environment = {
        PUID = "1000"; # Matches your user ID usually
        PGID = "100"; # 'users' group
        TZ = config.time.timeZone or "UTC";
        WEBUI_PORT = "8080";
      };
      autoStart = true;
    };
    # Transmission
    services.transmission = lib.mkIf cfg.transmission.enable {
      enable = true;

      settings = {
        download-dir = "${cfg.downloadDir}/complete";
        incomplete-dir = "${cfg.downloadDir}/incomplete";
        incomplete-dir-enabled = true;

        rpc-bind-address = "0.0.0.0";
        rpc-port = cfg.transmission.port;
        rpc-host-whitelist = lib.concatStringsSep "," [ "onix.local" ];
        rpc-host-whitelist-enable = true;
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
        "${cfg.downloadDir}/../youtube:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone or "UTC";
        PUID = "1000";
        PGID = "100";
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
