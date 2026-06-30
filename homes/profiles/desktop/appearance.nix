{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  local = {
    stylix.enable = true;
    fonts.enable = true;
  };

  gtk = {
    enable = mkForce true;
    gtk4.theme = mkForce null;
    font = {
      name = "Cascadia Code";
      package = pkgs.cascadia-code;
      size = 11;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs.kitty.font = {
    name = "Cascadia Code";
    size = 10;
  };

  home.packages = with pkgs; [
    # Fonts (for GUI)
    cascadia-code
  ];
}
