# Base profile - Common configuration for all systems
{ pkgs, ... }:
{
  local = {
    cache.enable = true;
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
    firefox.enable = true;
    gpu-screen-recorder.enable = true;
    git = {
      enable = true;
      config = {
        safe.directory = "/etc/nixos";
      };
    };
  };
}
