{
  pkgs,
  config,
  lib,
  inputs,
  self,
  ...
}:
let
  inherit (lib)
    generators
    getExe
    getExe'
    mkEnableOption
    mkIf
    mkForce
    mkOption
    types
    optionals
    ;
  getSystem = p: p.stdenv.hostPlatform.system;

  cfg = config.local.hyprland;
  variables = config.local.variables;
  hypr-tools = pkgs.hypr-tools;
  quick-menu = pkgs.quick-menu;
  cosmic-live = inputs.cosmic-live.packages.${getSystem pkgs}.default;
in
{
  options.local.hyprland = {
    enable = mkEnableOption "Functional Hyprland setup.";
    layout = mkOption {
      type = types.enum [
        "scrolling"
        "master"
      ];
      default = "master";
      description = "Which layout to use by default in Hyprland.";
    };
  };
  imports = [
    ./scrolling.nix
    ./master.nix
  ];
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      cliphist
      jq
      discord
      hypr-tools
      cosmic-live
      webcam
      webcam-menu
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      xwayland.enable = true;
      settings = {
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
          border_size = 6;
        };
        group = {
          groupbar = {
            font_size = 12;
            gradients = false;
            height = 1;
            text_offset = -8;
            indicator_height = 16;
            rounding = 5;
            gaps_out = 8;
            gaps_in = 5;
          };
        };
        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
        };
        decoration = {
          rounding = 20;
          active_opacity = "1.0";
          inactive_opacity = "0.95";
          fullscreen_opacity = "1.0";
          blur = {
            enabled = true;
          };
        };
        binds = {
          workspace_back_and_forth = true;
        };
        exec-once = [
          "wl-paste --type text --watch cliphist store"
          "${getExe cosmic-live} --wallpaper $HOME/.wallpaper"
        ]
        ++ variables.autostart
        ++ optionals config.local.caelestia-shell.enable [
          "caelestia wallpaper -f $HOME/.wallpaper"
        ];
        windowrules = [
          "float, class:^(webcam)$"
          "pin, class:^(webcam)$"
          "size 320 240, class:^(webcam)$"
          "move 100%-340 100%-260, class:^(webcam)$"
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
          "$mod, C, exec, ${getExe pkgs.webcam-menu}"
          "$mod, D, togglespecialworkspace, desktop"
          "$mod, minus, exec, hypr-screenshot full"
          "$mod_SHIFT, minus, exec, hypr-screenshot area"

          # Window management
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

          "$mod, T, togglegroup"
          "$mod, N, changegroupactive, f"
        ];
        bindm = [
          "$mod,mouse:272, movewindow"
          "$mod,mouse:273, resizewindow"
        ];
      };
    };
  };
}
