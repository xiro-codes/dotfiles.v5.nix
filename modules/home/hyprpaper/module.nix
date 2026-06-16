{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.local.hyprpaper;
in
{
  options.local.hyprpaper = {
    enable = mkEnableOption "Hyprpaper, the native Hyprland wallpaper daemon";
    wallpapers = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = literalExpression "[ ~/.wallpaper ]";
      description = "List of wallpaper paths to preload for Hyprpaper";
    };
  };

  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        preload = map (p: "${p}") cfg.wallpapers;
        wallpaper = [ ",${builtins.elemAt cfg.wallpapers 0}" ];
      };
    };
    local.variables.wallpaper = "hyprpaper";
  };
}
