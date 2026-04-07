# Base profile - Common configuration for all systems
{ pkgs, lib, ... }:
{
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" &&
          action.lookup("program") == "/run/current-system/sw/bin/nixos-container" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
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
    git = {
      enable = true;
      config = {
        safe.directory = "/etc/nixos";
      };
    };
  };
}
