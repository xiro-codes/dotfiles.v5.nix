{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.hyprlauncher;
in
{
  options.local.hyprlauncher = {
    enable = mkEnableOption "Hyprlauncher, the native Hyprland application launcher";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ hyprlauncher ];
    local.variables.launcher = "hyprlauncher";
  };
}
