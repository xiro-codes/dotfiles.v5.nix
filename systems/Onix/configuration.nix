{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/server
  ];
  local = {
    # System settings
    bootloader.recoveryUUID = "017aa821-7b75-492a-98cf-1174f1b15ea1";

    secrets.keys = [
      "harmonia_key"
      "gog_creds"
      "zerotier_network_id"
      "gitea/runner_token"
    ];
    zerotier.enable = true;
    containers.Jade.enable = true;
    virtualisation.incus.enable = false;
  };

  networking = {
    interfaces.enp5s0.ipv4.addresses = [
      {
        address = "192.168.1.65";
        prefixLength = 24;
      }
    ];
    # Keep enp6s0 on DHCP for containers, but don't use it for the default gateway if possible
    # though keeping it as is for now since user says containers go out on it.
  };

  services.openssh.listenAddresses = [
    {
      addr = "192.168.1.65";
      port = 22;
    }
  ];

  users.users.tod.extraGroups = [
    "minecraft"
    "incus-admin"
  ];

  boot = {
    swraid.mdadmConf = "MAILADDR root";
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
  };

  networking.nftables.enable = true;

  system.stateVersion = "25.11";
}
