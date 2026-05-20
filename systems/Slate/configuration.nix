{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/workstation
    ../profiles/workstation/jovian.nix
    ../profiles/client.nix
  ];

  local = {
    registry.enable = true;
    userManager.extraGroups = [
      "input"
      "uinput"
    ];
    yubikey.enable = true;
    bootloader.recoveryUUID = "deck-recovery-placeholder"; # TODO: Update after first install

    secrets.keys = [
      "gog_creds"
      "zerotier_network_id"
    ];

    zerotier.enable = true;
  };
  services.displayManager.sddm.enable = true;

  system.stateVersion = "25.11";

  topology.self.interfaces = {
    wlan0.network = "home";
    zt0.network = "zerotier";
  };
}
