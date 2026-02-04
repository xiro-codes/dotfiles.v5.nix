{ pkgs, config, lib, ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/workstation.nix
    #../profiles/zima-client.nix
    ../profiles/limine-uefi.nix
  ];
  # Ruby-specific configuration
  local = {
    # Secrets specific to Ruby
    disks.enable = true;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "zima_creds"
    ];

    # Ruby-specific bootloader UUID
    bootloader.recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";

    # Enable auto-upgrade for Ruby
    dotfiles.maintenance.autoUpgrade = true;

    # Additional share mounts for Ruby
    shareManager.mounts = lib.mkAfter [
      { shareName = "Porn"; localPath = "/media/Porn"; noShow = true; }
    ];
  };

  # Ruby-specific user
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  system.stateVersion = "25.11";
}
