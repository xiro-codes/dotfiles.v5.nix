{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  local = {
    cache.enable = true;
    secrets.keys = [ "gemini/api_key" "zima_creds" ];

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
        { shareName = "Books"; localPath = "/mnt/zima/Books"; }
      ];
    };
  };
  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKfhjzD1qn3TqTaBcY50mogz4cQGFI/0CMAMRw1hC7s tod@Ruby"
      ];
      shell = pkgs.fish;
    };
    tod = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKfhjzD1qn3TqTaBcY50mogz4cQGFI/0CMAMRw1hC7s tod@Ruby"
      ];
      shell = pkgs.fish;
    };
  };
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
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
  system.stateVersion = "25.11"; # Did you read the comment?

}
