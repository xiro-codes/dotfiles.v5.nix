{ config, lib, ... }:

let
  cfg = config.local.kitty;
in
{
  options.local.kitty = {
    enable = lib.mkEnableOption "Kitty terminal emulator with custom configuration";
  };

  config = lib.mkIf cfg.enable {
    local.variables.terminal = "kitty";
    programs.kitty = {
      enable = true;
      extraConfig = ''
        window_padding_width 5
      '';
    };
  };
}
