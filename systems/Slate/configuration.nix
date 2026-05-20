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
  ];

  local = {
    # System settings
    bootloader.recoveryUUID = "deck-recovery-placeholder"; # TODO: Update after first install

    secrets.keys = [
      "ssh_pub_deck/master"
    ];

    secrets.enable = mkForce false;
    security.enable = mkForce false;

    gaming.enable = true;
    desktops.enable = true;
    desktops.hyprland = mkForce false;
    desktops.displayManager = "none";
    desktops.plasma6 = true;
  };
  services.displayManager.sddm.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = mkForce true;
      PermitRootLogin = mkForce "yes";
    };
  };

  system.stateVersion = "25.11";
}
