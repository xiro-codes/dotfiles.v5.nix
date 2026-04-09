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
      one-step-from-eden.enable = true;
    };
  };
  boot.enableContainers = true;


  local = {
    disks.enable = true;

    yubikey.enable = true;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "ssh_pub_jade/master"
      "onix_creds"
      "gog_creds"
    ];

    bootloader.recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";

    recovery-builder.enable = true;

    dotfiles-sync.maintenance.autoUpgrade = true;

    dotfiles-sync.maintenance.upgradeFlake = "github:xiro-codes/dotfiles.v5.nix";

  };
  # Ruby-specific user
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "enp7s0";
    enableIPv6 = false;
  };
  hardware.keyboard.qmk.enable = true;
  boot.kernelParams = [ "video=HDMI-A-1:2560x1080@60" "video=DP-3:d" ];
  system.stateVersion = "25.11";
}
