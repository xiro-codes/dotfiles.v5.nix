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
  hostsCfg = config.local.network-hosts;
  primaryHost = hostsCfg.primary;
  primaryIp = hostsCfg.${primaryHost};
in
{
  options.local.network = {
    enable = mkEnableOption "Standard system networking";
    useProtonVpn = mkOption {
      type = types.bool;
      default = true;
      description = "enable protonvpn globally";
    };
    useNetworkManager = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use NetworkManager (for desktops) or just iwd/systemd (minimal).";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      hosts = {
        "${primaryIp}" = [
          "dashboard.${primaryHost}.home"
          "wallpapers.${primaryHost}.home"
          "games.${primaryHost}.home"
          "git.${primaryHost}.home"
          "plex.${primaryHost}.home"
          "${primaryHost}.home"
          "comics.${primaryHost}.home"
          "audiobooks.${primaryHost}.home"
          "dl.${primaryHost}.home"
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
