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

  cfg = config.local.nixarr-stack;
in
{
  options.local.nixarr-stack = {
    enable = mkEnableOption "nixarr media download stack";

    mediaDir = mkOption {
      type = types.str;
      default = "/media/Media";
      description = "Base directory for media files";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/data/.state/nixarr";
      description = "State directory for nixarr services";
    };

    vpn = {
      enable = mkEnableOption "VPN for download services";
      wgConfFile = mkOption {
        type = types.str;
        default = config.sops.secrets."protonvpn_wg_conf".path;
        description = "Path to WireGuard config file for VPN";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.vpn.enable -> config.local.secrets.enable;
        message = "nixarr-stack VPN requires local.secrets to be enabled";
      }
    ];

    nixarr = {
      enable = true;
      mediaDir = cfg.mediaDir;
      stateDir = cfg.stateDir;
      mediaUsers = [ "tod" ];

      # VPN (ProtonVPN via WireGuard)
      vpn = mkIf cfg.vpn.enable {
        enable = true;
        wgConf = cfg.vpn.wgConfFile;
      };

      # === Download Client ===
      qbittorrent = {
        enable = true;
        vpn.enable = cfg.vpn.enable;
        openFirewall = true;
      };

      # === Indexer Management ===
      prowlarr = {
        enable = true;
        openFirewall = true;
        settings-sync = {
          enable-nixarr-apps = true;
          tags = [ "torrent" ];
        };
      };

      # === TV Shows ===
      sonarr = {
        enable = true;
        openFirewall = true;
        settings-sync.downloadClients = [
          {
            name = "qBittorrent";
            implementation = "QBittorrent";
            fields = {
              host = "localhost";
              port = 8085;
            };
          }
        ];
      };

      # === Movies ===
      radarr = {
        enable = true;
        openFirewall = true;
        settings-sync.downloadClients = [
          {
            name = "qBittorrent";
            implementation = "QBittorrent";
            fields = {
              host = "localhost";
              port = 8085;
            };
          }
        ];
      };

      # === Music ===
      lidarr = {
        enable = true;
        openFirewall = true;
      };

      # === Subtitles ===
      bazarr = {
        enable = true;
        openFirewall = true;
        settings-sync = {
          sonarr.enable = true;
          radarr.enable = true;
        };
      };

      # === Media Servers ===
      jellyfin = {
        enable = true;
        openFirewall = true;
      };

      plex = {
        enable = true;
        openFirewall = true;
      };

      # === Books & Audio ===
      komga = {
        enable = true;
        openFirewall = true;
      };

      audiobookshelf = {
        enable = true;
        openFirewall = true;
      };
    };
    # Disable local authentication for settings-sync to authenticate with REST APIs
    services = {
      prowlarr.settings.auth.required = "DisabledForLocalAddresses";
      sonarr.settings.auth.required = "DisabledForLocalAddresses";
      radarr.settings.auth.required = "DisabledForLocalAddresses";
      lidarr.settings.auth.required = "DisabledForLocalAddresses";
    };
  };
}
