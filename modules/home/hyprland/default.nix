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

    home.packages = with pkgs; [
      wl-clipboard
      cliphist
      jq
      discord
    ];

    local = {
      mako.enable = false;
      waybar.enable = false;
      hyprlauncher.enable = false;
      shell.enable = true;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
        workspace = [
          "1, persistent:true"
          "2, persistent:true"
          "3, persistent:true"

          "7, presistent:true" # Plex
          "8, presistent: true" # Discord
          "9, presistent:true" # Steam
        ];
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
          gaps_out = 8;
          border_size = 2;
          layout = "master";

        };
        decoration = {
          rounding = 20;
        };
        binds = {
          workspace_back_and_forth = true;
        };
        exec-once = [
          "[workspace 9 silent] steam -silent"
          "[workspace 8 silent] discord"
          "[workspace 7 silent] plex-desktop"
          "wl-paste --type text --watch cliphist store"
        ];
        windowrulesv2 = [
          "workspace 7, initialClass:^(tv.plex.Plex)$"
          "workspace 8, class:^(discord)$"
          "workspace 9, initialClass:^(steam)$"
          "workspace 9, class:^(steam_app_.*)$"

          "focusonactivate, class:^(steam_app_.*)$"
          "float, class:^(steam)$, title:^(Friends List)$"
          "float, class:^(steam)$, title:^(Steam - News)$"
          "float, class:^(steam)$, title:^([Ss]ettings)$"
          "float, class:^(steam)$, title:^(.* - Chat)$"
          "float, class:^(steam)$, title:^(Contents)$"
          "float, class:^(steam)$, title:^(Video Player)$"
        ];
        "$mod" = "SUPER";

        bind = [
          "$mod, Return, exec, ${variables.terminal}"
          "$mod, Tab, exec, hyprctl dispatch workspace $(( ( $(hyprctl activeworkspace -j | jq '.id') % 3 ) + 1 ))"
          "$mod_SHIFT, Tab, exec, hyprctl dispatch workspace $(( ( $(hyprctl activeworkspace -j | jq '.id') - 2 + 3 ) % 3 + 1 ))"

          "$mod, G, workspace, 9" # Games
          "$mod, C, workspace, 8" # Chat
          "$mod, M, workspace, 7" # Media

          "$mod, E, exec, ${variables.guiFileManager}"
          "$mod_SHIFT, E, exec, ${variables.fileManager}"

          "$mod, P, exec, ${variables.launcher} "
          "$mod, Space, layoutmsg, swapwithmaster master"

          "$mod_SHIFT, Q, killactive"

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

          # "$mod, Tab, changegroupactive"
          # "$mod, G, togglegroup"

          "$mod, U, workspace, 1"
          "$mod, I, workspace, 2"
          "$mod, O, workspace, 3"

          "$mod_SHIFT, U, movetoworkspace, 1"
          "$mod_SHIFT, I, movetoworkspace, 2"
          "$mod_SHIFT, O, movetoworkspace, 3"

        ];
        bindm = [
          "$mod,mouse:272, movewindow"
          "$mod,mouse:273, resizewindow"
        ];

      };
    };
  };
}
