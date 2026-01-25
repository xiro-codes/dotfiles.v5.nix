{pkgs, ...}: {
  imports = [ ./hardware-configuration.nix ];
  local = {
    userManager.enable = true;
    repoManager.enable = true;
    gitSync.enable = true;
    settings.enable = true;
    network = {
      enable = true;
      useNetworkManager = true;
    };
  };
  programs.git = {
    enable = true;
    config = {
      safe.directory = "/etc/nixos";
    };
  };
  system.stateVersion = "25.11";
}
