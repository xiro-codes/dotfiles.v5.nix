{
  pkgs,
  config,
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib) range mkForce;
in
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/workstation
    ../profiles/client.nix
    inputs.tierfs.nixosModules.default
  ];

  programs = {
    coolercontrol.enable = true;
    gog = {
      enable = false;
      serverUrl = "https://games.${config.local.network-hosts.primary}.home";
      games = {
        tyranny-game.enable = true;
      };
    };
    nixbit = {
      enable = false;
      repository = "https://github.com/xiro-codes/dotfiles.v5.nix";
    };
  };
  boot.enableContainers = true;
  local = {
    userManager.extraGroups = [
      "adbusers"
      "dialout"
      "input"
      "uinput"
    ];
    nix-cache-client.enable = mkForce true;
    secrets.keys = [
      "gog_creds"
      "zerotier_network_id"
    ];

    bootloader.recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";

    dotfiles-sync.maintenance.upgradeFlake = "github:xiro-codes/dotfiles.v5.nix";
  };

  hardware.keyboard.qmk.enable = true;
  boot.kernelParams = [
    "video=HDMI-A-1:2560x1080@60"
  ];

  nxc.daemon = {
    enable = true;
    socketGroup = "wheel";
  };

  system.stateVersion = "25.11";
}
