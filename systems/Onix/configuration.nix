{
  pkgs,
  config,
  lib,
  inputs,
  self,
  ...
}:
{
  imports = with self.nixosModules; [
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
      "protonvpn_wg_conf"
    ];
    virtualisation.incus.enable = false;

  };

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
