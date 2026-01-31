# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  local = {
    cache.enable = true;

    bootloader = {
      mode = "uefi";
      uefiType = "systemd-boot";
      device = "/dev/nvme0n1";
    };
    backup-manager = {
      enable = true;
      paths = [
        "/etc/nixos/" #dotfiles
        "/etc/ssh/ssh_host_rsa_key" # Ruby system private key
        "/etc/ssh/ssh_host_rsa_key.pub" # Ruby system public key
        "/etc/ssh/ssh_host_ed25519_key" # Ruby system private key
        "/etc/ssh/ssh_host_ed25519_key.pub" #Ruby system public key

        # TODO have nix generate this list for all users 
        "/home/tod/Projects/"
        "/home/tod/Documents/"
        "/home/tod/Pictures/"
        "/home/tod/Videos"

        # TODO home manager actiovation script to generate these keys on first boot?
        "/home/tod/.ssh/id_sops" #tod@Ruby sops private key
        "/home/tod/.ssh/id_sops.pub" #tod@Ruby sops public key
        "/home/tod/.ssh/github" #xiro-code github private key
        "/home/tod/.ssh/github.pub" #xiro-code github public key
      ];
      exclude = [
        "*/.cache"
        "*/target"
        "*/node_modules"
        "*/.direnv"
        "*/known_hosts"
        "*/result"
      ];
      backupLocation = "/mnt/zima/Backups";
    };
    maintenance = {
      enable = true;
      autoUpgrade = true;
    };

    userManager.enable = true;
    repoManager.enable = true;
    gitSync.enable = true;
    settings.enable = true;
    network = {
      enable = true;
      useNetworkManager = true;
    };
    audio.enable = true;
    bluetooth.enable = true;
    gaming.enable = true;
    desktops = {
      enable = true;
      enableEnv = true;
      hyprland = true;
    };
    shareManager = {
      enable = true;
      serverIp = "10.0.0.65";
      mounts = [
        { shareName = "Backups"; localPath = "/mnt/zima/Backups"; }
        { shareName = "Music"; localPath = "/mnt/zima/Music"; }
      ];
    };
  };
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  services.sshd.enable = true;
  environment.systemPackages = with pkgs; [ cliphist ];
  programs = {
    firefox.enable = true;
    gpu-screen-recorder.enable = true;
    git = {
      enable = true;
      config = {
        safe.directory = "/etc/nixos";
      };
    };
  };
  system.stateVersion = "25.11"; # Did you read the comment?

}
