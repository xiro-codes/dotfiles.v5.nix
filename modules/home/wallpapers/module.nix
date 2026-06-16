{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.local.wallpapers;
  # Access the wallpapers package from flake outputs
  wallpapers = pkgs.wallpapers;
in
{
  options.local.wallpapers = {
    enable = mkEnableOption "Centralized wallpaper management";
    name = mkOption {
      type = types.str;
      default = "miku.jpeg";
      description = "The name of the wallpaper file to use from the wallpapers package";
    };
    path = mkOption {
      type = types.path;
      readOnly = true;
      default = "${wallpapers}/${cfg.name}";
      description = "The full path to the currently selected wallpaper image";
    };
  };

  config = mkIf cfg.enable {
    # Symlink the selected wallpaper to a predictable location in the home directory
    home.file.".wallpaper".source = cfg.path;
  };
}
