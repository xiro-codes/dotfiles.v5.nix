{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.waybar;
in
{
  options.local.waybar = {
    enable = mkEnableOption "Waybar status bar for Wayland compositors";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pavucontrol
      jq
      wttrbar
    ];
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
      settings = pkgs.callPackage ./settings.nix {
        inherit pkgs;
        cfg = config.local;
      };
      style = ./style.css;
    };
  };
}
