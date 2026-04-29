{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.mako;
in
{
  options.local.mako = {
    enable = mkEnableOption "Mako notification daemon for Wayland";
  };

  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      padding = "15";
      borderSize = 2;
      borderRadius = 5;
    };
  };
}
