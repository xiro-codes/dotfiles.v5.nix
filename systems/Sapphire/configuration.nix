{ lib, config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/workstation.nix
    ../profiles/limine-uefi.nix
    ../profiles/client.nix
  ];

  # Sapphire-specific configuration
  local = {
    # Secrets specific to Sapphire

    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_sapphire/master"
      "ssh_pub_ruby/master"
      "ssh_pub_onix/master"
      "onix_creds"
    ];

    # Sapphire-specific bootloader UUID
    bootloader.recoveryUUID = "0d9dddd8-9511-4101-9177-0a80cfbeb047";

    # Enable auto-upgrade for Sapphire
    dotfiles.maintenance.autoUpgrade = true;

    # Backup dotfiles on Sapphire
    backup-manager.paths = lib.mkAfter [
      "/etc/nixos/"
    ];
  };

  # Sapphire-specific user
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  system.stateVersion = "25.11"; # Did you read the comment?

}
