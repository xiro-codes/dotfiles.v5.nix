{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    optional
    ;
  cfg = config.local.virtualisation.incus;
in
{
  options.local.virtualisation.incus = {
    enable = mkEnableOption "Incus virtualisation";
    ui = {
      enable = mkEnableOption "Incus UI";
    };
    macvlanInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Physical interface to attach macvlan network to.";
    };
    storageSource = mkOption {
      type = types.str;
      default = "/var/lib/incus/storage";
      description = "Path for the default storage pool.";
    };
    enableReverseProxy = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to configure the reverse proxy for the Incus UI/socket.";
    };
  };

  config = mkIf cfg.enable {
    networking.nftables.enable = true;
    networking.firewall.trustedInterfaces = [ "incusbr0" ];

    networking.bridges.incusbr0.interfaces = [ ];

    networking.macvlans = mkIf (cfg.macvlanInterface != null) {
      macvlan0 = {
        interface = cfg.macvlanInterface;
        mode = "bridge";
      };
    };

    virtualisation.incus = {
      enable = true;
      ui.enable = cfg.ui.enable;
      preseed = {
        config = {
          "core.https_address" = "127.0.0.1:8443";
        };
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv6.address" = "none";
            };
          }
        ]
        ++ (
          if cfg.macvlanInterface != null then
            [
              {
                name = "macvlan0";
                type = "macvlan";
                config = {
                  parent = cfg.macvlanInterface;
                };
              }
            ]
          else
            [ ]
        );
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "dir";
            config = {
              source = cfg.storageSource;
            };
          }
        ];
      };
    };

    local.reverse-proxy.services.vm = mkIf cfg.enableReverseProxy {
      target = "http://unix:/var/lib/incus/unix.socket:/";
    };

    users.users.nginx.extraGroups = mkIf cfg.enableReverseProxy [ "incus-admin" ];
  };
}
