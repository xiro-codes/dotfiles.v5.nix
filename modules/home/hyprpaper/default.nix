{pkgs, lib, config, ...}: let 
  cfg = config.local.hyprpaper;
in {
  options.local.hyprpaper = {
    enable = lib.mkEnableOption "Native Hyprland wallpaper daemon";
    wallpapers = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "List of wallpapers to preload";
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
