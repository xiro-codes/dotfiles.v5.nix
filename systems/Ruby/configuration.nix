{ pkgs, config, lib, ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];
  local = {
    cache.enable = true;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "zima_creds"
    ];
    security.enable = true;
    bootloader = {
      mode = "uefi";
      uefiType = "limine";
      device = "/dev/nvme0n1";
      addRecoveryOption = true;
      recoveryUUID = "b0cd9860-736a-45c5-a6d2-e69cdb319f24";
    };
    backup-manager = {
      enable = true;
      paths = [
        "/root/.ssh"
        #"/etc/nixos/" # dotfiles
        "/etc/ssh/ssh_host_rsa_key" # Ruby system private key
        "/etc/ssh/ssh_host_rsa_key.pub" # Ruby system public key
        "/etc/ssh/ssh_host_ed25519_key" # Ruby system private key
        "/etc/ssh/ssh_host_ed25519_key.pub" # Ruby system public key
      ];
      exclude = [
        "*/.cache"
        "*/target"
        "*/node_modules"
        "*/.direnv"
        "*/known_hosts"
        "*/config"
        "*/result"
      ];
      backupLocation = "/mnt/zima/Backups";
    };
    dotfiles = {
      enable = true;
      maintenance = {
        enable = true;
        autoUpgrade = true;
      };
      repo.enable = true;
      sync.enable = true;
    };
    userManager.enable = true;
    settings.enable = true;
    localization.enable = true;
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
        {
          shareName = "Backups";
          localPath = "/mnt/zima/Backups";
          noAuth = true;
          noShow = true;
        }
        { shareName = "Music"; localPath = "/mnt/zima/Music"; }
        { shareName = "Books"; localPath = "/mnt/zima/Books"; }
        { shareName = "Porn"; localPath = "/mnt/zima/Porn"; noShow = true; }
      ];
    };
  };
  users.users = {
    root.shell = pkgs.fish;
    tod = {
      shell = pkgs.fish;
      initialPassword = "rockman";
    };
  };

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
  system.stateVersion = "25.11";
}
