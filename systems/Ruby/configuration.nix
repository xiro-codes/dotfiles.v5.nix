{ pkgs, config, ... }:
{
  imports = [ ./hardware-configuration.nix ];
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
    };
    backup-manager = {
      enable = true;
      paths = [
        "/root/.ssh"
        "/etc/nixos/" # dotfiles
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
      mounts = [
        {
          shareName = "Backups";
          localPath = "/mnt/zima/Backups";
          noAuth = true;
          noShow = true;
        }
        {
          shareName = "Music";
          localPath = "/mnt/zima/Music";
        }
        {
          shareName = "Books";
          localPath = "/mnt/zima/Books";
        }
        {
          shareName = "Porn";
          localPath = "/mnt/zima/Porn";
          noShow = true;
        }
      ];
    };
  };
  users.users = {
    root = {
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        config.sops.secrets."ssh_pub_sapphire/master".path
        config.sops.secrets."ssh_pub_ruby/master".path
      ];
    };
    tod = {
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        config.sops.secrets."ssh_pub_sapphire/master".path
        config.sops.secrets."ssh_pub_ruby/master".path
      ];
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
  system.stateVersion = "25.11";
}
