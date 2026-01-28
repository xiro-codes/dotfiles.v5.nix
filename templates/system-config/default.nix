{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  local = {
    cache.enable = true;
    bootloader = {
      mode = "TEMPLATE_BOOT_MODE";
      uefiType = "TEMPLATE_UEFI_TYPE";
      device = "TEMPLATE_DISK";
    };
    maintenance = {
      enable = true;
      autoUpgrade = true;
    };
    audio.enable = true;
    bluetooth.enable = true;
    gaming.enable = true;
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

  services.sshd.enable = true;
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
