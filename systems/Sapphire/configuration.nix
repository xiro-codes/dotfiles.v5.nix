{
  lib,
  config,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) mkForce mkAfter;
in
{
  imports = with self.nixosModules; [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/server
    # ../profiles/client.nix
    # ../profiles/workstation
    # ../profiles/workstation/jovian.nix
  ];

  # Sapphire-specific configuration
  local = {
    nix-builders = {
      enable = mkForce true;
      hosts = [ "ruby" ];
    };
    protonvpn.enable = true;
    bootloader.addRecoveryOption = mkForce false;
    secrets.keys = [
      "harmonia_key"
      "gog_creds"
      "zerotier_network_id"
      "gitea/runner_token"
      "protonvpn_wg_conf"
    ];

    virtualisation.incus = {
      enable = true;
      storageSource = "/media/Scratch/incus";
      ui.enable = true;
    };

    coolercontrol.enable = true;
  };

  users.users.tod.extraGroups = [
    "minecraft"
    "incus-admin"
  ];

  system.stateVersion = "25.11";

  topology.self.interfaces = {
    enp8s0.network = "home";
    wg0.network = "vpn";
    zt0.network = "zerotier";
  };

  topology.self.services = {
    Dashboard = {
      name = "Homepage Dashboard";
      info = "Main Server Dashboard";
    };
    Gitea = {
      name = "Gitea";
      info = "Git Server";
      icon = "services.gitea";
    };
    Plex = {
      name = "Plex";
      info = "Media Server";
    };
    Qbittorrent = {
      name = "qBittorrent";
      info = "Torrent Client";
    };
    Harmonia = {
      name = "Harmonia";
      info = "Binary Cache";
    };
    CoolerControl = {
      name = "CoolerControl";
      info = "System Cooling Web UI";
      icon = "services.coolercontrol";
    };
  };
}
