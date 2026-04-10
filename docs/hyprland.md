# hyprland

This module provides a functional Hyprland setup, configuring the window manager with a set of personal preferences and utilities. It enables Hyprland, configures workspaces, monitors, input settings, general appearance, decorations, keybindings, and startup applications. It also includes packages for clipboard management, scripting, and communication.  Furthermore, it introduces dynamic workspaces using sets via the `hypr-workspace-set` utility from hypr-tools.

## Options

- `local.hyprland.enable`
  - Type: `boolean`
  - Default: `false`
  - Description: Enables the functional Hyprland setup.  When enabled, the module configures Hyprland with specified settings, keybindings, and autostart applications.  This is the main switch to activate the Hyprland configuration defined within this module.

## Configuration

The following settings are applied when `local.hyprland.enable` is set to `true`:

- **Packages:** Installs necessary packages via `home.packages`.
  - `pkgs.wl-clipboard`: Command-line clipboard utilities for Wayland. Enables copying and pasting between applications.
  - `pkgs.cliphist`: Clipboard history manager.  Records clipboard content, providing a history for pasting previous items.
  - `pkgs.jq`: Lightweight and flexible command-line JSON processor.  Useful for manipulating JSON data in scripts or configurations.
  - `pkgs.discord`: Communication platform.
  - `hypr-tools`: Custom helper scripts.

- **Hyprland Settings:** Configures Hyprland via `wayland.windowManager.hyprland.settings`.

  - `enable`: Enables Hyprland window manager. Set to `true`.
  - `xwayland.enable`: Enables XWayland support, allowing X11 applications to run under Hyprland.
  - `workspace`: Defines persistent workspaces with layouts.
    - `"1, persistent:true"`: Workspace 1, persistent.
    - `"2, persistent:true"`: Workspace 2, persistent.
    - `"3, persistent:true, layout:scrolling"`: Workspace 3, persistent, with scrolling layout.
    - `"4, persistent:true"`: Workspace 4, persistent.
    - `"5, persistent:true"`: Workspace 5, persistent.
    - `"6, persistent:true, layout:scrolling"`: Workspace 6, persistent, with scrolling layout.
    - `"7, persistent:true"`: Workspace 7, persistent.
    - `"8, persistent:true"`: Workspace 8, persistent.
    - `"9, persistent:true, layout:scrolling"`: Workspace 9, persistent, with scrolling layout.
  - `monitor`: Configures monitor settings.
    - `"HDMI-A-1,preferred,auto,1"`: Configures the `HDMI-A-1` monitor with preferred settings, auto resolution and a scale of `1`.
    - `"DP-3, disabled"`: Disables the `DP-3` monitor.
  - `input`: Configures input devices.
    - `kb_layout = "us"`: Sets the keyboard layout to US English.
    - `follow_mouse = 1`: Makes windows follow the mouse focus.
    - `sensitivity = 0`: Sets the input sensitivity to the default value.
    - `touchpad.natural_scroll = false`: Disables natural scrolling for the touchpad.
  - `general`: General Hyprland settings.
    - `gaps_in = 5`: Sets the inner gap size between windows to 5 pixels.
    - `gaps_out = 8`: Sets the outer gap size between windows and the screen edge to 8 pixels.
    - `border_size = 2`: Sets the window border size to 2 pixels.
    - `layout = "master"`: Sets the default window layout to "master".
  - `misc`: Miscellaneous settings.
    - `disable_hyprland_logo = true`: Disables the Hyprland logo.
    - `force_default_wallpaper = 0`: Disables forcing the default wallpaper.
  - `decoration`: Window decoration settings.
    - `rounding = 20`: Sets the window rounding radius to 20 pixels.
    - `active_opacity = "1.0"`: Sets the opacity of active windows to 1.0 (fully opaque).
    - `inactive_opacity = "0.95"`: Sets the opacity of inactive windows to 0.95.
    - `fullscreen_opacity = "1.0"`: Sets the opacity of fullscreen windows to 1.0.
    - `blur.enabled = false`: Disables window blurring.
  - `binds`:
    - `workspace_back_and_forth = true`: Enables quick workspace switching.
  - `exec-once`: Commands executed once at startup.
    - `"wl-paste --type text --watch cliphist store"`: Watches the clipboard and stores text entries to cliphist.
    - `"steam -silent"`: Starts Steam in silent mode.
    - `"discord --start-minimized"`: Starts Discord minimized to the system tray.
    - `"caelestia wallpaper set $HOME/.wallpaper"`: This is conditionally included if `config.local.caelestia-shell.enable` is true, setting wallpaper.
  - `"$mod"`: Sets the modifier key to `SUPER` (Windows key).
  - `bind`: Defines keybindings.
    - `"$mod, Return, exec, ${variables.terminal}"`: Opens the terminal.
    - `"$mod, Tab, exec, hypr-switch-set next"`: Switches to the next workspace set.
    - `"$mod_SHIFT, Tab, exec, hypr-switch-set prev"`: Switches to the previous workspace set.
    - `"$mod, U, exec, hypr-workspace-set u"`: Navigates to workspace `u` within the current set.
    - `"$mod, I, exec, hypr-workspace-set i"`: Navigates to workspace `i` within the current set.
    - `"$mod, O, exec, hypr-workspace-set o"`: Navigates to workspace `o` within the current set.
    - `"$mod_SHIFT, U, exec, hypr-move-to-set u"`: Moves the current window to workspace `u` within the current set.
    - `"$mod_SHIFT, I, exec, hypr-move-to-set i"`: Moves the current window to workspace `i` within the current set.
    - `"$mod_SHIFT, O, exec, hypr-move-to-set o"`: Moves the current window to workspace `o` within the current set.
    - `"$mod, P, exec, ${variables.launcher} "`: Opens the application launcher.
    - `"$mod, D, exec, ${lib.getExe quick-menu}"`: Opens the custom quick menu.
    - `"$mod, minus, exec, caelestia shell lock lock"`: Locks the screen.
    - `"$mod, N, exec, caelestia shell drawers toggle sidebar"`: Toggles the sidebar.
    - `"$mod, C, togglespecialworkspace, chromeos"`: Toggles the "chromeos" special workspace.
    - `"$mod, Space, layoutmsg, swapwithmaster master"`: Swaps the focused window with the master window.
    - `"$mod_SHIFT, Q, killactive"`: Kills the active window.
    - `"$mod, F, fullscreen"`: Toggles fullscreen mode for the focused window.
    - `"$mod_SHIFT, F, togglefloating"`: Toggles floating mode for the focused window.
    - `"$mod, H, movefocus, l"`: Moves focus left.
    - `"$mod, J, movefocus, d"`: Moves focus down.
    - `"$mod, K, movefocus, u"`: Moves focus up.
    - `"$mod, L, movefocus, r"`: Moves focus right.
    - `"$mod_SHIFT, H, movewindow, l"`: Moves the focused window left.
    - `"$mod_SHIFT, J, movewindow, d"`: Moves the focused window down.
    - `"$mod_SHIFT, K, movewindow, u"`: Moves the focused window up.
    - `"$mod_SHIFT, L, movewindow, r"`: Moves the focused window right.
  - `bindm`: Defines mouse bindings.
    - `"$mod,mouse:272, movewindow"`: Moves the window when dragging with the left mouse button.
    - `"$mod,mouse:273, resizewindow"`: Resizes the window when dragging with the right mouse button.

## Helpers

- `mkMenu`: A function that creates a quick-menu using `wlr-which-key` based on the passed-in configuration.  The menu configuration is written to `config.yaml` and used by `wlr-which-key` to display the menu.
- `quick-menu`: A pre-configured quick menu with options for launching a web browser (`zen`), file manager (`nautilus`), volume control (`pavucontrol`), Discord, and Hyprland gaming mode (`hypr-gaming-mode`). The menu items include a keybinding and a description for each action.

