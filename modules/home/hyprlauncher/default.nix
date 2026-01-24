{pkgs, lib, config, ...}: let 
  cfg = config.local.hyprlauncher;
  inherit (lib) mkOption types mkIf mkEnableOption;
in {
  options.local.hyprlauncher.enable = mkEnableOption "Enable native hyprland launcher";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ hyprlauncher ];
    local.variables.launcher = "hyprlauncher";
  };
}
