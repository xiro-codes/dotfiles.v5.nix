{
  pkgs,
  config,
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib) range mkForce mkDefault;
in
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/workstation
    ../profiles/client.nix
    ../profiles/remote-builder.nix
  ];

  programs = {
    gog = {
      enable = true;
      serverUrl = "https://games.${config.local.network-hosts.primary}.home";
      games = {
        tyranny-game.enable = false;
      };
    };
  };
  boot.enableContainers = true;
  local = {
    nix-builders.hosts = [ ]; # Prevent Ruby from offloading builds to slower machines
    valent.enable = true;
    coolercontrol.enable = true;
    userManager.extraGroups = [
      "adbusers"
      "dialout"
      "input"
      "uinput"
    ];
    harmonia-client = {
      enable = mkForce true;
      publicKey = "cache.sapphire.home-1:T6/FA9b6BgZvvvoXIzc4y/5MJgPs2GVHpi0KcU/fUMo=";
    };


    bootloader.recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";

    dotfiles-sync.maintenance.upgradeFlake = "github:xiro-codes/dotfiles.v5.nix";
  };

  hardware.keyboard.qmk.enable = true;
  boot.kernelParams = mkDefault [
    "video=HDMI-A-1:2560x1080@60"
    "video=DP-3:d"
  ];

  nxc.daemon = {
    enable = true;
    socketGroup = "wheel";
  };

  system.stateVersion = "25.11";

  topology.self.interfaces = {
    enp7s0.network = "home";
  };
}
