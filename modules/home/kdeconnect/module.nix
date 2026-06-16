{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.kdeconnect;
in
{
  options.local.kdeconnect = {
    enable = mkEnableOption "enable kdeconnect";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ kdePackages.kdeconnect-kde ];
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
