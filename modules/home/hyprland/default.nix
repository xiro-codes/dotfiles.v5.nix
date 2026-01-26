{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.local.hyprland;
  variables = config.local.variables;

in
{
  options.local.hyprland = {
    enable = lib.mkEnableOption "Functional Hyprland setup.";
  };
  config = lib.mkIf cfg.enable {
    home.file.".wallpaper".source = ./gruvbox.png;

    home.packages = with inputs.self.packages.x86_64-linux; [
      recording-toggle
    ];

    local = {
      mako.enable = true;
      waybar.enable = true;
      hyprlauncher.enable = true;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
        monitor = [
          ",preferred,auto,1"
        ];
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad.natural_scroll = false;
        };
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          layout = "master";
        };
        decoration = {
          rounding = 10;
        };

        exec-once = [
          "steam -silent"
          "${pkgs.swaybg}/bin/swaybg -m fill -i ~/.wallpaper"
        ];

        "$mod" = "SUPER";

        bind = [
          "$mod, Return, exec, ${variables.terminal}"

          "$mod, E, exec, ${variables.guiFileManager}"
          "$mod_SHIFT, E, exec, ${variables.fileManager}"

          "$mod, P, exec, ${variables.launcher} "
          "$mod, Space, layoutmsg, swapwithmaster master"

          "$mod_SHIFT, Q, killactive"

          "$mod, R, exec, recording-toggle"
          "$mod, F, fullscreen"
          "$mod_SHIFT, F, togglefloating"

          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"

          "$mod_SHIFT, H, movewindow, l"
          "$mod_SHIFT, J, movewindow, d"
          "$mod_SHIFT, K, movewindow, u"
          "$mod_SHIFT, L, movewindow, r"

          "$mod, Tab, changegroupactive"
          "$mod, G, togglegroup"

          "$mod, U, workspace, 1"
          "$mod, I, workspace, 2"
          "$mod, O, workspace, 3"

          "$mod_SHIFT, U, movetoworkspace, 1"
          "$mod_SHIFT, I, movetoworkspace, 2"
          "$mod_SHIFT, O, movetoworkspace, 3"

          "$mod, M, workspace, 4"
          "$mod, comma, workspace, 5"
          "$mod, period, workspace, 6"

          "$mod_SHIFT, M, movetoworkspace, 4"
          "$mod_SHIFT, comma,   movetoworkspace, 5"
          "$mod_SHIFT, period, movetoworkspace, 6"
        ];
        bindm = [
          "$mod,mouse:272, movewindow"
          "$mod,mouse:273, resizewindow"
        ];

      };
    };
  };
}
