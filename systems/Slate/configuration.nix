{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./btrfs-rollback.nix
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

    secrets.enable = lib.mkForce false;
    security.enable = lib.mkForce false;

    gaming.enable = true;
    desktops.enable = true;
    desktops.hyprland = lib.mkForce false;
    desktops.displayManager = "none";
    desktops.plasma6 = true;
  };
  services.displayManager.sddm.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkForce true;
      PermitRootLogin = lib.mkForce "yes";
    };
  };

  system.stateVersion = "25.11";
}
