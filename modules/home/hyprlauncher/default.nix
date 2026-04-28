{ config, lib, pkgs, ... }:

let
  cfg = config.local.hyprlauncher;
in
{
  options.local.hyprlauncher = {
    enable = lib.mkEnableOption "Hyprlauncher, the native Hyprland application launcher";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ hyprlauncher ];
    local.variables.launcher = "hyprlauncher";
  };
}
