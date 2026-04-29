{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.kitty;
in
{
  options.local.kitty = {
    enable = mkEnableOption "Kitty terminal emulator with custom configuration";
  };

  config = mkIf cfg.enable {
    local.variables.terminal = "kitty";
    programs.kitty = {
      enable = true;
      extraConfig = ''
        window_padding_width 5
      '';
    };
  };
}
