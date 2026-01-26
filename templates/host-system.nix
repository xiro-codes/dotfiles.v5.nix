{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  local = {
    cache.enable = true;
    bootloader = {
      mode = "TEMPLATE_BOOT_MODE";
      uefiType = "TEMPLATE_UEFI_TYPE";
      device = "TEMPLATE_DISK";
    };
    userManager.enable = true;
    repoManager.enable = true;
    gitSync.enable = true;
    settings.enable = true;
    network = {
      enable = true;
      useNetworkManager = true;
    };
    desktops = {
      enable = true;
      enableEnv = true;
      hyprland = true;
    };
  };
  users.users.TEMPLATE_USER = {
    shell = pkgs.fish;
    initialPassword = "TEMPLATE_PASS";
  };
  programs.firefox.enable = true;
  programs.git = {
    enable = true;
    config = {
      safe.directory = "/etc/nixos";
    };
  };
  system.stateVersion = "25.11";
}
