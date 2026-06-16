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

        # Neovim-like splits and pane navigation
        enabled_layouts splits

        # Create splits (vsplit = right, hsplit = down)
        map ctrl+w>v launch --location=vsplit
        map ctrl+w>s launch --location=hsplit

        # Navigate splits
        map ctrl+w>h neighboring_window left
        map ctrl+w>l neighboring_window right
        map ctrl+w>k neighboring_window up
        map ctrl+w>j neighboring_window down

        # Close split
        map ctrl+w>q close_window
      '';
    };
  };
}
