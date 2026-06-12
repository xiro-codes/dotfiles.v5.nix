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

  };

  users.users.tod.extraGroups = [
    "minecraft"
    "incus-admin"
  ];

  system.stateVersion = "25.11";

  topology.self.interfaces = {
    eth0.network = "home";
    zt0.network = "zerotier";
  };
}
