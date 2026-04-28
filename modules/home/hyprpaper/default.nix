{ config, lib, ... }:

let
  cfg = config.local.hyprpaper;
in
{
  options.local.hyprpaper = {
    enable = lib.mkEnableOption "Hyprpaper, the native Hyprland wallpaper daemon";
    wallpapers = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      example = lib.literalExpression ''[ ~/.wallpaper ]'';
      description = "List of wallpaper paths to preload for Hyprpaper";
    };
  };

  config = lib.mkIf cfg.enable {
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
