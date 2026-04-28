{ config, lib, pkgs, ... }:

let
  cfg = config.local.kdeconnect;
in
{
  options.local.kdeconnect = {
    enable = lib.mkEnableOption "enable kdeconnect";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ kdePackages.kdeconnect-kde ];
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
