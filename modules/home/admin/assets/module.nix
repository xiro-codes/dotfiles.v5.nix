{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  
  # When running under NixOS integration, default to osConfig if available, otherwise fallback to true.
  defaultEnable = if osConfig != null then osConfig.local.assets.enableExternal else true;
  # We should use osConfig.local.network-hosts.primary if available, but Home Manager might not have it natively
  # in standalone mode. Assuming standalone mode won't rely on `network-hosts` or it's hardcoded.
  # Let's provide a fallback string just in case.
  primaryHost = if osConfig != null then osConfig.local.network-hosts.primary else "sapphire";

  cfg = config.local.assets;
in
{
  options.local.assets = {
    enableExternal = mkOption {
      type = types.bool;
      default = defaultEnable;
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
        "${pkgs.wallpapers}/Muse Dash - All Illustrations/interlude_46.png"
      else
        pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;

    local.assets.wallpapers.miku =
      if cfg.enableExternal then
        "${pkgs.wallpapers}/Muse Dash - All Illustrations/06022025114952_interlude_105.png"
      else
        pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;

    local.assets.icons.user =
      if cfg.enableExternal then
        "${pkgs.icons}/evil_genius_avatars/Eli_b.jpg"
      else
        pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;
  };
}
