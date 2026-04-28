{ config, lib, ... }:

let
  cfg = config.local.mako;
in
{
  options.local.mako = {
    enable = lib.mkEnableOption "Mako notification daemon for Wayland";
  };

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
      padding = "15";
      borderSize = 2;
      borderRadius = 5;
    };
  };
}
