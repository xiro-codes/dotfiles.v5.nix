{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.virtualisation.incus;
in
{
  options.local.virtualisation.incus = {
    enable = mkEnableOption "Incus virtualisation";
    ui = {
      enable = mkEnableOption "Incus UI";
    };
  };

  config = mkIf cfg.enable {
    networking.nftables.enable = true;
    networking.firewall.trustedInterfaces = [ "incusbr0" ];

    networking.bridges.incusbr0.interfaces = [];
    networking.macvlans.macvlan0 = {
      interface = "enp6s0";
      mode = "bridge";
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
          {
            name = "macvlan0";
            type = "macvlan";
            config = {
              parent = "enp6s0";
            };
          }
        ];
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
              source = "/media/storage/incus";
            };
          }
        ];
      };
    };

    local.reverse-proxy.services.vm = {
      target = "http://unix:/var/lib/incus/unix.socket:/";
    };

    users.users.nginx.extraGroups = [ "incus-admin" ];
  };
}