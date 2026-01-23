{ config, lib, ... }:

let
  cfg = config.local.network;
in {
  options.local.network = {
    enable = lib.mkEnableOption "Standard system networking";
    useNetworkManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use NetworkManager (for desktops) or just iwd/systemd (minimal).";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      # Disable the old wpa_supplicant
      wireless.enable = false;
      
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
      networkmanager = lib.mkIf cfg.useNetworkManager {
        enable = true;
        # Force NetworkManager to use iwd as the backend
        wifi.backend = "iwd";
      };

      # Basic Ethernet support (DHCP) for all interfaces starting with 'e'
      useDHCP = lib.mkDefault true;
    };

    # Optional: Enable systemd-resolved for better DNS handling
    services.resolved.enable = true;
  };
}
