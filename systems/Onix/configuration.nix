{ pkgs, config, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/server
  ];
  local = {
    kmscon.enable = true;
    # System settings
    disks.enable = true;
    network-hosts.useAvahi = true;
    bootloader.recoveryUUID = "017aa821-7b75-492a-98cf-1174f1b15ea1";
    docs.enable = lib.mkForce false;
    media = {
      jellyfin.enable = lib.mkForce false;
      ersatztv.enable = lib.mkForce false;
    };

    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "ssh_pub_jade/master"
      "harmonia_key"
      "onix_creds"
      "gog_creds"
      "zerotier_network_id"
    ];
    gog-downloader = {
      enable = true;
      directory = "/media/Media/games";
      secretFile = config.sops.secrets."gog_creds".path;
    };
    zerotier.enable = true;
  };

  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };

  boot = {
    swraid.mdadmConf = "MAILADDR root";
    kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  };

  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
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

  system.stateVersion = "25.11";
}
