{
  pkgs,
  config,
  lib,
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
    ../profiles/client.nix
    ../profiles/workstation
  ];
  services.openssh.settings = {
    PasswordAuthentication = mkForce true;
    PermitRootLogin = mkForce "yes";
  };

  programs = {
    coolercontrol.enable = true;
    gog = {
      enable = false;
      serverUrl = "https://games.onix.home";
      games = {
        tyranny-game.enable = true;
      };
    };
  };
  boot.enableContainers = true;
  local = {
    registry.enable = true;
    userManager.extraGroups = [
      "adbusers"
      "dialout"
      "input"
      "uinput"
    ];
    yubikey.enable = true;
    secrets.keys = [
      "gog_creds"
      "zerotier_network_id"
    ];

    bootloader.recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";

    dotfiles-sync.maintenance.upgradeFlake = "github:xiro-codes/dotfiles.v5.nix";
    zerotier.enable = true;
  };

  hardware.keyboard.qmk.enable = true;
  boot.kernelParams = [
    "video=HDMI-A-1:2560x1080@60"
  ];

  users.users.build = {
    isNormalUser = true;
    description = "Nix remote build user";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7231Oawo+cIcWU22G0qfWh5N77r0neXl0ZSTWLQz+f build@installer-iso"
    ];
  };

  nix.settings.trusted-users = [ "build" ];

  system.stateVersion = "25.11";
}
