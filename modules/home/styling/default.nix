{ config, lib, pkgs, ... }:

let
  cfg = config.local;
in
{
  options.local = {
    # Fonts
    fonts = {
      enable = lib.mkEnableOption "Nerd Fonts collection including Fira Code, Noto fonts, and emoji support";
    };

    # Stylix theming
    stylix = {
      enable = lib.mkEnableOption "Stylix automatic theming system based on wallpaper colors";
    };
  };

  config = lib.mkMerge [
    # Fonts
    (lib.mkIf cfg.fonts.enable {
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
    (lib.mkIf cfg.stylix.enable {
      # Create .wallpaper symlink in home directory
      home.file.".wallpaper".source = ./wallpaper.jpg;

      stylix = {
        enable = true;
        image = ./wallpaper.jpg;
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
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
