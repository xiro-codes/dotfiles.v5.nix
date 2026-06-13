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
  config = mkIf (cfg.enable && cfg.layout == "scrolling") {
    wayland.windowManager.hyprland.settings = {
      general.layout = "scrolling";
      workspace = [
        "1, persistent:true"
        "2, persistent:true"
        "3, persistent:true"
        "4, persistent:true"
        "5, persistent:true"
        "6, persistent:true"
        "7, persistent:true"
        "8, persistent:true"
        "9, persistent:true"
      ];
      bind = [
        # Scrolling specific bindings
        # Currently no specific bindings needed beyond the common ones
      ];
    };
  };
}
