{ ... }:
{
  imports = [
    ../base
    ./tools.nix
  ];

  local = {
    nixvim.enable = true;
    ranger.enable = true;

    # No GUI features
    fonts.enable = false;
    stylix.enable = false;
    hyprland.enable = false;
    kitty.enable = false;
    mpd.enable = false;
    caelestia.enable = false;
  };
}
