{ lib, config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/client.nix
    ../profiles/ai-server
  ];

  # Sapphire-specific configuration
  local = {
    bootloader.recoveryUUID = "0d9dddd8-9511-4101-9177-0a80cfbeb047";

    backup-manager.paths = lib.mkAfter [
      "/etc/nixos/"
    ];
  };

  system.stateVersion = "25.11";

}
