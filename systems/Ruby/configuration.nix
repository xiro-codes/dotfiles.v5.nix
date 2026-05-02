{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) range;
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
    cluster = {
      enable = true;
      size = 10;
      template = "Amber";
    };
  };
  services.nginx = {
    enable = true;
    upstreams."test_cluster".servers = lib.listToAttrs (
      map (i: {
        name = "10.233.0.${toString i}:80";
        value = { };
      }) (range 1 config.local.cluster.size)
    );

    virtualHosts."localhost" = {
      locations."/" = {
        proxyPass = "http://test_cluster/index.html";
        extraConfig = ''
          default_type text/html; 
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

        '';
      };
    };
  };
  hardware.keyboard.qmk.enable = true;
  boot.kernelParams = [
    "video=HDMI-A-1:2560x1080@60"
    "video=DP-3:d"
  ];
  system.stateVersion = "25.11";
}
