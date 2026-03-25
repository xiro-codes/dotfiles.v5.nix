{ pkgs, lib, ... }:
{
  local = {
    stylix.enable = true;
    fonts.enable = true;
  };

  gtk = {
    enable = lib.mkForce true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.packages = with pkgs; [
    # Fonts (for GUI)
    cascadia-code
  ];
}
