{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.local.hyprland;
in
{
  config = mkIf (cfg.enable && cfg.layout == "master") {
    wayland.windowManager.hyprland.settings = {
      general.layout = "master";
      workspace = [
        "1, persistent:true, layout:master"
        "2, persistent:true, layout:master"
        "3, persistent:true, layout:master"
        "4, persistent:true, layout:master"
        "5, persistent:true, layout:master"
        "6, persistent:true, layout:master"
        "7, persistent:true, layout:master"
        "8, persistent:true, layout:master"
        "9, persistent:true, layout:master"
      ];
      master = {
        mfact = 0.5;
        new_status = "master";
        new_on_top = true;
      };
      bind = [
        # Master layout specific bindings
        "$mod, Space, layoutmsg, swapwithmaster master"
      ];
    };
  };
}
