{ pkgs, config, lib, ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/client.nix
    ../profiles/workstation
  ];
  programs = {
    coolercontrol.enable = true;
    gog = {
      enable = true;
      serverUrl = "https://games.onix.home";
      games = {
        tyranny-game.enable = true;
      };
    };
  };
  boot.enableContainers = true;


  local = {
    userManager.extraGroups = [ "adbusers" "dialout" ];
    yubikey.enable = true;
    secrets.keys = [
      "gog_creds"
    ];

    bootloader.recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";

    dotfiles-sync.maintenance.upgradeFlake = "github:xiro-codes/dotfiles.v5.nix";

  };
  # Ruby-specific user
  # Note: user 'tod' is now defined in profiles/base.nix

  hardware.keyboard.qmk.enable = true;
  boot.kernelParams = [ "video=HDMI-A-1:2560x1080@60" "video=DP-3:d" ];
  system.stateVersion = "25.11";
}
