{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  local = {
    cache.enable = true;
    bootloader = {
      mode = "uefi";
      uefiType = "limine";
      device = "/dev/nvme0n1";
    };
    backup-manager = {
      enable = true;
      paths = [
        "/home/tod/Documents/"
      ];
      exclude = [
        "*/.cache"
        "*/target"
        "*/node_modules"
        "*/.direnv"
      ];
      backupLocation = "/mnt/zima/backups/ruby";
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
  programs.firefox.enable = true;
  programs.gpu-screen-recorder.enable = true;
  programs.git = {
    enable = true;
    config = {
      safe.directory = "/etc/nixos";
    };
  };
  system.stateVersion = "25.11";
}
