{ config, lib, ... }:

let
  inherit (lib) mkDefault mkEnableOption mkIf mkOption types;

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
    usePihole = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to prioritize the local Pi-hole (192.168.1.65) for DNS.";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      hosts = {
        "192.168.1.65" = [
          "yt.onix.home"
          "dashboard.onix.home"
          "files.onix.home"
          "wallpapers.onix.home"
          "games.onix.home"
          "git.onix.home"
          "tv.onix.home"
          "plex.onix.home"
          "onix.home"
          "ch7.onix.home"
          "comics.onix.home"
          "audiobooks.onix.home"
          "dl.onix.home"
          "pihole.onix.home"
          "docs.onix.home"
          "cache.onix.home"
        ];
      };
      # Disable the old wpa_supplicant
      wireless.enable = false;
      firewall.allowedTCPPorts = [ 5201 5202 ];
      # Prioritize Pi-hole if enabled
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
    services.avahi = {
      enable = false;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
    # Optional: Enable systemd-resolved for better DNS handling
    services.resolved.enable = false;

  };
}
