{pkgs, lib, config, ...}:
let 
  inherit (lib ) mkOption types mkIf;
  cfg = config.local.fonts;
in {
    options.local.fonts = {
      enable = lib.mkEnableOption "Enable nerdfonts";
    };
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.symbols-only
        noto-fonts
        noto-fonts-color-emoji
        twemoji-color-font
      ];
      fonts.fontconfig.enable = true;
    };
}
