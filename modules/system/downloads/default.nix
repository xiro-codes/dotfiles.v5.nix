{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.downloads;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
in
{
  options.local.downloads = {
    enable = mkEnableOption "download services";

    downloadDir = mkOption {
      type = types.str;
      default = "${config.local.media.mediaDir}/downloads";
      example = "/mnt/storage/downloads";
      description = "Base directory for downloads";
    };
    qbittorrent = {
      enable = mkEnableOption "Transmission BitTorrent client";

      port = mkOption {
        type = types.port;
        default = 8080;
        description = "Web interface port";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall ports for Transmission";
      };

      subPath = mkOption {
        type = types.str;
        default = "";
        example = "/qbittorrent";
        description = "Subpath for reverse proxy (e.g., /transmission)";
      };
    };

    pinchflat = {
      enable = mkEnableOption "Pinchflat YouTube downloader";

      port = mkOption {
        type = types.port;
        default = 8945;
        description = "Web interface port";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall port for Pinchflat";
      };
    };
  };

  config = mkIf cfg.enable {
    # Ensure download directories exist
    # 1. Create the "Real" Folder and Copy Files
    systemd.services.init-qbittorrent-config = mkIf cfg.qbittorrent.enable {
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
    services.qbittorrent = mkIf cfg.qbittorrent.enable {
      enable = true;
      openFirewall = cfg.qbittorrent.openFirewall;
      webuiPort = cfg.qbittorrent.port;
    };

    # Pinchflat
    services.pinchflat = mkIf cfg.pinchflat.enable {
      enable = true;
      mediaDir = "${cfg.downloadDir}/../youtube";
      port = cfg.pinchflat.port;
      openFirewall = cfg.pinchflat.openFirewall;
      selfhosted = true;
    };
  };
}
