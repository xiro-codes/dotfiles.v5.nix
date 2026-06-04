{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.network;
in
{
  options.local.network = {
    enable = mkEnableOption "Standard system networking";
    useNetworkManager = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use NetworkManager (for desktops) or just iwd/systemd (minimal).";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      hosts = {
        "192.168.1.67" = [
          "yt.sapphire.home"
          "dashboard.sapphire.home"
          "files.sapphire.home"
          "wallpapers.sapphire.home"
          "games.sapphire.home"
          "git.sapphire.home"
          "tv.sapphire.home"
          "plex.sapphire.home"
          "sapphire.home"
          "ch7.sapphire.home"
          "comics.sapphire.home"
          "audiobooks.sapphire.home"
          "dl.sapphire.home"
          "pihole.sapphire.home"
          "docs.sapphire.home"
          "cache.sapphire.home"
        ];
      };
      # Disable the old wpa_supplicant
      wireless.enable = false;
      firewall.allowedTCPPorts = [
        5201
        5202
      ];
      # Always enable iwd (it's faster and more modern)
      nameservers = [ "8.8.8.8" ];
      wireless.iwd = {
        enable = true;
        settings = {
          Settings = {
            AutoConnect = true;
          };
          Network = {
            EnableIPv6 = true;
          };
        };
      };

      # Conditional NetworkManager setup
      networkmanager = mkIf cfg.useNetworkManager {
        enable = true;
        # Force NetworkManager to use iwd as the backend
        wifi.backend = "iwd";
      };

      # Basic Ethernet support (DHCP) for all interfaces starting with 'e'
      useDHCP = mkDefault true;
    };
    # Optional: Enable systemd-resolved for better DNS handling
    services.resolved.enable = false;
  };
}
