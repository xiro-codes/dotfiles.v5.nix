{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  local = {
    cache.enable = true;
    bootloader = {
      mode = "uefi";
      uefiType = "systemd-boot";
      device = "/dev/nvme0n1";
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
  };
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  services.sshd.enable = true;
  programs.firefox.enable = true;
  programs.git = {
    enable = true;
    config = {
      safe.directory = "/etc/nixos";
    };
  };
  system.stateVersion = "25.11";
}
