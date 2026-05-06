{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.local;
in
{
  options.local = {
    # Fonts
    fonts = {
      enable = mkEnableOption "Nerd Fonts collection including Fira Code, Noto fonts, and emoji support";
    };

    # Stylix theming
    stylix = {
      enable = mkEnableOption "Stylix automatic theming system based on wallpaper colors";
    };
  };

  config = mkMerge [
    # Fonts
    (mkIf cfg.fonts.enable {
      home.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.symbols-only
        noto-fonts
        noto-fonts-color-emoji
        twemoji-color-font
      ];
      fonts.fontconfig.enable = true;
    })

    # Stylix
    (mkIf cfg.stylix.enable {
      local.wallpapers.enable = true;

      programs.fuchsia-cursor = {
        enable = true;
        name = "Stylix-fuchsia";
        stylixIntegration.enable = true;
      };

      stylix = {
        enable = true;
        image = config.local.wallpapers.path;
        cursor = {
          size = 16;
        };
        opacity = {
          applications = 1.0;
          terminal = 0.95;
          desktop = 1.0;
          popups = 0.95;
        };
        targets = {
          nixvim.colors.enable = true;
          nixvim.fonts.enable = true;
          kitty.fonts.enable = true;
          kitty.colors.enable = false; # Let caelestia handle colors
          hyprland.enable = false; # Let caelestia handle hyprland colors
          firefox.enable = false;
          zen-browser.enable = true;
          zen-browser.profileNames = [ "default" ];
          gtk.enable = true; # Disable GTK theming
          qt.enable = false; # Disable Qt theming
        };
        fonts = {
          monospace = {
            package = pkgs.cascadia-code;
            name = "Cascadia Code";
          };
          serif = config.stylix.fonts.monospace;
          sansSerif = config.stylix.fonts.monospace;
          sizes = {
            applications = 11;
            terminal = 10;
            desktop = 10;
            popups = 10;
          };
        };
      };
    })
  ];
}
