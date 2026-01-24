# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  local = {
    desktops = {
      enable = true;
      enableEnv = true;
      hyprland = true;
      plasma6 = false;
    };
    #backupManager.enable = true;
    userManager.enable = true;
    repoManager.enable = true;
    shareManager = {
      enable = true;
      serverIp = "10.0.0.65";
      mounts = [
        {shareName = "Music"; localPath = "/mnt/zima/Music";}
      ];
    };

    gitSync.enable = true;

    bluetooth.enable = true;
    audio.enable = true;
    gaming.enable = true;
    settings.enable = true;
    network = {
      enable = true;
      useNetworkManager = true;
    };

  };

  users.users.tod.shell = pkgs.fish;
  programs.firefox.enable = true;
  programs.git = {
    enable = true;
    config = {
      safe.directory = "/etc/nixos";
    };
  };
  system.stateVersion = "25.11"; # Did you read the comment?

}
