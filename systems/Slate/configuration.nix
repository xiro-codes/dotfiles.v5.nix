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
    ../../profiles/base.nix
    ../../profiles/limine-uefi.nix
    ../../profiles/workstation
    ../../profiles/workstation/jovian.nix
  ];

  local = {
    # System settings
    bootloader.recoveryUUID = "deck-recovery-placeholder"; # TODO: Update after first install

    persistence = {
      enable = true;
      persistentStoragePath = "/persist";
      directories = [
        "/var/lib/sops-nix"
        "/etc/ssh"
      ];
    };

    secrets.keys = [
      "ssh_pub_deck/master"
    ];

    secrets.enable = lib.mkForce false;
    security.enable = lib.mkForce false;

    gaming.enable = true;
  };


  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/disk/by-label/nixos /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date +%Y-%m-%d_%H-%M-%S)
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9 -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  system.stateVersion = "25.11";
}
