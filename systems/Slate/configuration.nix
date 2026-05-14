{
  lib,
  config,
  pkgs,
  ...
}:
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

    impermanence= {
      enable = true;
      persistentStoragePath = "/persist";
      directories = [
        "/var/lib/sops-nix"
        "/etc/ssh"
      ];
      files = [
        { file = "/etc/machine-id"; inInitrd = true;}
      ];
    };

    secrets.keys = [
      "ssh_pub_deck/master"
    ];

    secrets.enable = lib.mkForce false;
    security.enable = lib.mkForce false;

    gaming.enable = true;
  };



  system.stateVersion = "25.11";
}
