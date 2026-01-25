{ config, lib, pkgs, ... }:

let
  cfg = config.local.mako;
in
{
  options.local.mako = {
    enable = lib.mkEnableOption "mako module";
  };

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
      font = "Cascadia Code 11";
      padding = "15";
      borderSize = 2;
      borderRadius = 5;
    };
  };
}
