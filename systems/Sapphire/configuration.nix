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
    ../profiles/client.nix
    # ../profiles/workstation
    # ../profiles/workstation/jovian.nix
    ../profiles/server
  ];

  # Sapphire-specific configuration
  local = {
    bootloader.recoveryUUID = "0d9dddd8-9511-4101-9177-0a80cfbeb047";

    secrets.keys = [
      "harmonia_key"
      "gog_creds"
      "zerotier_network_id"
      "gitea/runner_token"
      "protonvpn_wg_conf"
    ];

    containers.Jade.enable = false;
    virtualisation.incus.enable = false;

    metrics.domain = "pihole.sapphire.home";

    # Disable network-mounts since Sapphire is now the server
    network-mounts.enable = mkForce false;

    backup-manager.paths = mkAfter [
      "/etc/nixos/"
    ];
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
