{
  config,
  lib,
  flake-inputs,
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

  cfg = config.local.network-interfaces;
  hostsCfg = config.local.network-hosts;
  primaryHost = hostsCfg.primary;
  primaryIp = hostsCfg.${primaryHost};

  capitalize = str:
    let
      firstChar = builtins.substring 0 1 str;
      rest = builtins.substring 1 (-1) str;
    in
      lib.toUpper firstChar + rest;

  primaryHostCap = capitalize primaryHost;
  primaryConfig = flake-inputs.self.nixosConfigurations.${primaryHostCap}.config;
  reverseProxyCfg = primaryConfig.local.reverse-proxy;
  
  serviceDomains = map (name: "${name}.${primaryHost}.home") (builtins.attrNames reverseProxyCfg.services);
  folderDomains = map (name: "${name}.${primaryHost}.home") (builtins.attrNames reverseProxyCfg.sharedFolders);
  
  dynamicDomains = serviceDomains ++ folderDomains ++ [ "${primaryHost}.home" ];
in
{
  options.local.network-interfaces = {
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
        "${primaryIp}" = dynamicDomains;
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
