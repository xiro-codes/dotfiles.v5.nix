{ pkgs, config, lib, ... }:

let
  cfg = config.local.desktops;
  inherit (lib) mkOption mkIf mkForce;
  inherit (lib.types) bool;
in {
  options.local.desktops = {
    enable = mkOption {
      type = bool;
      default = false;
    };
    enableEnv = mkOption {
      type = bool;
      default = true;
    };
    hyprland = mkOption {
      type = bool;
      default = false;
    };
    niri = mkOption {
      type = bool;
      default = false;
    };
    plasma6 = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Core Desktop Requirements
    xdg.portal.enable = true;
    
    environment.systemPackages = with pkgs; [
      xdg-user-dirs
      xdg-utils
    ];

    # Modern Wayland Environment Variables
    environment.variables = mkIf cfg.enableEnv {
      NIXOS_OZONE_WL = "1";
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland";
      GDK_DPI_SCALE = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";
      WARP_ENABLE_WAYLAND = "1";
    };

    # The Ly Display Manager (Replaces greetd)
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
        restore = true;
        save = true;
      };
    };

    # Desktop Selection logic using inputs from your flake
    programs.hyprland = mkIf cfg.hyprland {
      enable = true;
      withUWSM = false;
    };

    # Niri Support
    programs.niri = mkIf cfg.niri {
      enable = true;
    };

    # Plasma 6 Support
    services.desktopManager.plasma6.enable = cfg.plasma6;
  };
}
