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
    gog.games = {
      pillars-of-eternity.enable = true;
      luftrausers.enable = true;
      bastion.enable = true;
      one-step-from-eden.enable = true;
      book-of-hours.enable = true;
    };
  };

  local = {
    disks.enable = true;

    yubikey.enable = true;

    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "onix_creds"
      "gog_creds"
    ];

    bootloader.recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";

    dotfiles-sync.maintenance.autoUpgrade = true;

    dotfiles-sync.maintenance.upgradeFlake = "github:xiro-codes/dotfiles.v5.nix";

  };
  # Ruby-specific user
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  hardware.keyboard.qmk.enable = true;
  boot.kernelParams = [ "video=HDMI-A-1:2560x1080@60" "video=DP-3:d" ];
  system.stateVersion = "25.11";
}
