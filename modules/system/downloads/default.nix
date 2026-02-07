{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.downloads;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
in
{
  options.local.downloads = {
    enable = lib.mkEnableOption "download services";

    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.local.media.mediaDir}/downloads";
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

    pinchflat = {
      enable = lib.mkEnableOption "Pinchflat YouTube downloader";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8945;
        description = "Web interface port";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Pinchflat";
      };

    };


  };

  config = lib.mkIf cfg.enable {
    # Ensure download directories exist
    # 1. Create the "Real" Folder and Copy Files
    systemd.services.init-qbittorrent-config = lib.mkIf cfg.qbittorrent.enable {
      description = "Initialize qBittorrent config for passwordless access";
      wantedBy = [ "services.qbittorrent.service" ];
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
        sed -i '/\\[Preferences\\]/a WebUI\\AuthSubnetWhitelistEnabled=true\\nWebUI\\AuthSubnetWhitelist=0.0.0.0/0' "$CONF_FILE"
      '';
    };
    services.qbittorrent = lib.mkIf cfg.qbittorrent.enable {
      enable = true;
      openFirewall = cfg.qbittorrent.openFirewall;
      webuiPort = cfg.qbittorrent.port;
    };

    # Pinchflat
    services.pinchflat = lib.mkIf cfg.pinchflat.enable {
      enable = true;
      mediaDir = "${cfg.downloadDir}/../youtube";
      port = cfg.pinchflat.port;
      openFirewall = cfg.pinchflat.openFirewall;
      selfhosted = true;
    };
  };
}
