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
  };

  config = mkIf cfg.enable {
    networking = {
      # Disable the old wpa_supplicant
      wireless.enable = false;
      firewall.allowedTCPPorts = [ 5201 5202 ];
      nameservers = [ "10.0.0.65" "8.8.8.8" ];
      # Always enable iwd (it's faster and more modern)
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
