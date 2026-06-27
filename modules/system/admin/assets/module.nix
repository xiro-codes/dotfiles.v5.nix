{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.local.assets;
in
{
  options.local.assets = {
    enableExternal = mkOption {
      type = types.bool;
      default = true;
      description = "Fetch assets from the external centralized server. If false, falls back to nixos-artwork defaults.";
    };

    wallpapers = {
      main = mkOption {
        type = types.path;
        description = "Path to the main wallpaper image.";
      };
      miku = mkOption {
        type = types.path;
        description = "Path to the miku wallpaper image.";
      };
    };

    icons = {
      user = mkOption {
        type = types.path;
        description = "Path to the user profile icon.";
      };
    };
  };

  config = {
    local.assets.wallpapers.main =
      if cfg.enableExternal then
        "${pkgs.wallpapers}/Muse_Dash_-_All_Illustrations/interlude_46.png"
      else
        pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;

    local.assets.wallpapers.miku =
      if cfg.enableExternal then
        "${pkgs.wallpapers}/Muse_Dash_-_All_Illustrations/06022025114952_interlude_105.png"
      else
        pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;

    local.assets.icons.user =
      if cfg.enableExternal then
        "${pkgs.icons}/evil_genius_avatars/Eli_b.jpg"
      else
        pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;
  };
}
