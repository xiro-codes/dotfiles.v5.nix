{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.local.hyprland;
  variables = config.local.variables;
  hypr-tools = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hypr-tools;
  mkMenu = menu:
    let
      configFile = pkgs.writeText "config.yaml" (lib.generators.toYAML { } {
        anchor = "bottom-right";
        inherit menu;
      });
    in
    pkgs.writeShellScriptBin "quick-menu" ''
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';
  quick-menu = mkMenu [
    { key = "w"; desc = "Web Browser"; cmd = "zen"; }
    { key = "f"; desc = "File Manager"; cmd = "nautilus"; }
    { key = "v"; desc = "Volume Control"; cmd = "pavucontrol"; }
    { key = "d"; desc = "Discord"; cmd = "discord"; }
    { key = "g"; desc = "Big Screen Gaming"; cmd = "hypr-gaming-mode"; }
  ];
in
{
  options.local.hyprland = {
    enable = lib.mkEnableOption "Functional Hyprland setup.";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      cliphist
      jq
      discord
      hypr-tools
    ];


    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
        workspace = [
          "1, persistent:true"
          "2, persistent:true"
          "3, persistent:true, layout:scrolling"
          "4, persistent:true"
          "5, persistent:true"
          "6, persistent:true, layout:scrolling"
          "7, persistent:true"
          "8, persistent:true"
          "9, persistent:true, layout:scrolling"
        ];
        monitor = [
          "HDMI-A-1,preferred,auto,1"
          "DP-3, disabled"
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
          active_opacity = "1.0";
          inactive_opacity = "0.95";
          fullscreen_opacity = "1.0";
          blur = {
            enabled = false;
          };
        };
        binds = {
          workspace_back_and_forth = true;
        };
        exec-once = [
          "wl-paste --type text --watch cliphist store"
          "steam -silent"
          "discord --start-minimized"
        ] ++ lib.optionals config.local.caelestia-shell.enable [
          "caelestia wallpaper set $HOME/.wallpaper"
        ];
        "$mod" = "SUPER";

        bind = [
          "$mod, Return, exec, ${variables.terminal}"

          # Workspace set switching
          "$mod, Tab, exec, hypr-switch-set next"
          "$mod_SHIFT, Tab, exec, hypr-switch-set prev"

          # Dynamic workspace navigation (U/I/O adapts to current set)
          "$mod, U, exec, hypr-workspace-set u"
          "$mod, I, exec, hypr-workspace-set i"
          "$mod, O, exec, hypr-workspace-set o"

          # Move windows to workspaces in current set
          "$mod_SHIFT, U, exec, hypr-move-to-set u"
          "$mod_SHIFT, I, exec, hypr-move-to-set i"
          "$mod_SHIFT, O, exec, hypr-move-to-set o"

          # Application launchers
          "$mod, P, exec, ${variables.launcher} "
          "$mod, D, exec, ${lib.getExe quick-menu}"
          "$mod, minus, exec, caelestia shell lock lock"
          "$mod, N, exec, caelestia shell drawers toggle sidebar"
          # Window management
          "$mod, C, togglespecialworkspace, chromeos"
          "$mod, Space, layoutmsg, swapwithmaster master"
          "$mod_SHIFT, Q, killactive"
          "$mod, F, fullscreen"
          "$mod_SHIFT, F, togglefloating"

          # Focus movement
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"

          # Window movement
          "$mod_SHIFT, H, movewindow, l"
          "$mod_SHIFT, J, movewindow, d"
          "$mod_SHIFT, K, movewindow, u"
          "$mod_SHIFT, L, movewindow, r"
        ];
        bindm = [
          "$mod,mouse:272, movewindow"
          "$mod,mouse:273, resizewindow"
        ];

      };
    };
  };
}
