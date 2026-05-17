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

    impermanence = {
      enable = true;
      persistentStoragePath = "/persist";
      directories = [
        "/var/lib/sops-nix"
        "/etc/ssh"
        "/var/lib/nixos"
        { directory = "/home/tod/.local/share/Steam"; user = "tod"; group = "users"; }
        { directory = "/home/tod/.steam"; user = "tod"; group = "users"; }
      ];
      files = [
        "/etc/machine-id"
      ];
    };

    secrets.keys = [
      "ssh_pub_deck/master"
    ];

    secrets.enable = lib.mkForce false;
    security.enable = lib.mkForce false;

    gaming.enable = true;
    desktops.enable = true;
    desktops.hyprland.enable = lib.mkForce false;
    desktops.displayManager = "none";
    desktops.plasma6.enable = true;
  };
  services.displayManager.sddm.enable = true;

  system.stateVersion = "25.11";

  fileSystems."/persist".neededForBoot = true;
}
