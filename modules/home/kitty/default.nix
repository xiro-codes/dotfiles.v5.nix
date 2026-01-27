{ pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.local.kitty;
in
{
  options.local.kitty = {
    enable = lib.mkEnableOption "Enable kitty";
  };
  config = mkIf cfg.enable {
    local.variables.terminal = "kitty";
    programs.kitty = {
      enable = true;
      extraConfig = ''
        window_padding_width 5
      '';
      # font = {
      # package = pkgs.cascadia-code;
      # name = "CascadiaCode";
      # size = 10;
      # };
      #extraConfig = lib.readFile ./theme.conf;
    };
  };
}
