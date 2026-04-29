# Base profile - Common configuration for all systems
{ pkgs, lib, ... }:
{
  local = {
    #secrets.enable = lib.mkForce false;
    #cache.enable = false;
    security.enable = true;
    dotfiles-sync = {
      enable = true;
      maintenance.enable = true;
      repo.enable = true;
      sync.enable = true;
    };
    userManager.enable = true;
    nix-core-settings.enable = true;
    localization.enable = true;
    disks.enable = true;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "ssh_pub_jade/master"
      "onix_creds"
    ];
    network = {
      enable = true;
      useNetworkManager = true;
    };
  };
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
  
  # Common user configuration
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  users.users.root.shell = pkgs.fish;

  # Common system packages
  environment.systemPackages = with pkgs; [
    cliphist
  ];

  # Common programs
  programs = {
    git = {
      enable = true;
      config = {
        safe.directory = "/etc/nixos";
      };
    };
  };
}
