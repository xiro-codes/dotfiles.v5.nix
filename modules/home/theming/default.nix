{ config, lib, pkgs, ... }:

let
  cfg = config.local.theming;
in
{
  options.local.theming = {
    enable = lib.mkEnableOption "theming module";

  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      image = ./gruvbox.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
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
        neovim.enable = false;
        kitty.fonts.enable = true;
        kitty.colors.enable = false;
        hyprland.enable = true;
        firefox.enable = true;
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
  };
}
