{ ... }:
{
  imports = [
    ../base
    ./tools.nix
  ];

  local = {
    nixvim.enable = true;
    yazi.enable = true;

    # No GUI features
    fonts.enable = false;
    stylix.enable = false;
    hyprland.enable = false;
    kitty.enable = false;
    mpd.enable = false;
    caelestia-shell.enable = false;
  };
}
