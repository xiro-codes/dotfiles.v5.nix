{pkgs, config, lib, ...}: let 
  inherit (lib) mkIf mkOption types;
  cfg = config.local.kitty;
in {
  options.local.kitty = {
    enable = lib.mkEnableOption "Enable kitty";
  };
  config = mkIf cfg.enable {
    local.variables.terminal = "kitty";
    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.cascadia-code;
        name = "CascadiaCode";
        size = 10;
        };
      };
  };
}
