# Base profile - Common configuration for all systems
{ pkgs, lib, ... }:
{
  local = {
    #secrets.enable = lib.mkForce false;
    #cache.enable = false; # Broken
    security.enable = true;
    dotfiles = {
      enable = true;
      maintenance.enable = true;
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
  };

  # Common user configuration
  users.users.root.shell = pkgs.fish;

  # Common system packages
  environment.systemPackages = with pkgs; [
    cliphist
  ];

  # Common programs
  programs = {
    firefox.enable = false;
    gpu-screen-recorder.enable = false;
    git = {
      enable = true;
      config = {
        safe.directory = "/etc/nixos";
      };
    };
  };
}
