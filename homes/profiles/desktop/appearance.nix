{
  pkgs,
  lib,
  ...
}:

{
  local = {
    stylix.enable = true;
    fonts.enable = true;
  };



  home.packages = with pkgs; [
    # Fonts (for GUI)
    cascadia-code
  ];
}
