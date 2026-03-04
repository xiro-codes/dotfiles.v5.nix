# Hyprland

This module provides a functional Hyprland setup, configuring the window manager with various settings, keybindings, and window rules. It also installs commonly used packages for a Hyprland environment.

## Options

### `local.hyprland.enable`

<sup>Type: boolean</sup>

<sup>Default: `false`</sup>

Enables the functional Hyprland setup.  When enabled, this option configures Hyprland with a set of predefined settings, keybindings, window rules, and installs essential packages. Disabling this option will prevent the Hyprland configuration from being applied.  This is the main switch to control whether or not Hyprland is configured by this module.

## Configuration Details

When `local.hyprland.enable` is set to `true`, the following configurations are applied:

### Installed Packages

The following packages are installed:

*   `wl-clipboard`: Command-line tool to access Wayland clipboard.
*   `cliphist`: Clipboard history manager.
*   `jq`: Command-line JSON processor.
*   `discord`: Discord application.
*   `hypr-tools`: Custom Hyprland tools package.

### Hyprland Settings

The following Hyprland settings are configured:

*   **`wayland.windowManager.hyprland.enable`**: Enables Hyprland.
*   **`wayland.windowManager.hyprland.xwayland.enable`**: Enables Xwayland support.
*   **`wayland.windowManager.hyprland.settings`**: A detailed set of Hyprland configurations.

    *   **`workspace`**: Defines persistent workspaces with optional layouts:
        *   Workspaces 1, 2, 4, 5, 7, and 8 are created as standard persistent workspaces.
        *   Workspaces 3, 6, and 9 are created as persistent workspaces with a scrolling layout.

    *   **`monitor`**: Configures monitors:
        *   `HDMI-A-1` is configured as the preferred monitor with auto settings and a scale of 1.
        *   `DP-3` is explicitly disabled.

    *   **`input`**: Sets input configurations:
        *   `kb_layout` is set to "us" for the keyboard layout.
        *   `follow_mouse` is enabled (set to 1).
        *   `sensitivity` is set to 0.
        *   `touchpad.natural_scroll` is disabled (set to `false`).

    *   **`general`**: Defines general settings:
        *   `gaps_in` is set to 5 (inner gaps).
        *   `gaps_out` is set to 8 (outer gaps).
        *   `border_size` is set to 2.
        *   `layout` is set to "master".

    *   **`decoration`**: Sets decoration settings:
        *   `rounding` is set to 20 for window corner rounding.
        *   `active_opacity` is set to "1.0" (fully opaque).
        *   `inactive_opacity` is set to "0.95" (slightly transparent).
        *   `fullscreen_opacity` is set to "1.0" (fully opaque in fullscreen).
        *   `blur.enabled` is disabled (`false`).

    *   **`binds`**: Configures general binds
        *   `workspace_back_and_forth` is enabled.

    *   **`exec-once`**: Commands executed once on startup:
        *   `wl-paste --type text --watch cliphist store` is executed to monitor clipboard changes and store them in `cliphist`.
        *   If `config.local.caelestia.enable` is also enabled, then `caelestia wallpaper set $HOME/.wallpaper` is also executed.

    *   **`windowrulesv2`**: Defines window rules v2:
        *   `focusonactivate, class:^(steam_app_.*)$`: Focuses on activation for all steam applications.
        *   `float, class:^(steam)$, title:^(Friends List)$`: Floats the Steam Friends List window.
        *   `float, class:^(steam)$, title:^(Steam - News)$`: Floats the Steam News window.
        *   `float, class:^(steam)$, title:^([Ss]ettings)$`: Floats the Steam Settings window.
        *   `float, class:^(steam)$, title:^(.* - Chat)$`: Floats Steam chat windows.
        *   `float, class:^(steam)$, title:^(Contents)$`: Floats the Steam Contents window.
        *   `float, class:^(steam)$, title:^(Video Player)$`: Floats the Steam Video Player window.
        *   `float, initialclass:^(org.pulseaudio.pavucontrol)$`: Floats the PulseAudio Volume Control window.
        *   `float, initialclass:^(org.gnome.nautilus)$`: Floats Nautilus (GNOME File Manager).
        *   `float, initialclass:^(discord)$`: Floats the Discord window.
        *   `idleinhibit always, class:^(steamapp_(default|[0-9]+)|gamescope|.*)$, fullscreen:1`: Prevents idle inhibiting for Steam applications, gamescope, and any other application in fullscreen.
        *   `idleinhibit always, fullscreen:1`: Prevents idle inhibiting for any fullscreen application.

    *   **`$mod`**: Sets the modifier key to `SUPER` (Windows key).

    *   **`bind`**: Defines keybindings:
        *   `$mod, Return, exec, ${variables.terminal}`: Opens the configured terminal.
        *   `$mod, Tab, exec, hypr-switch-set next`: Switch to the next workspace set.
        *   `$mod_SHIFT, Tab, exec, hypr-switch-set prev`: Switch to the previous workspace set.
        *   `$mod, U, exec, hypr-workspace-set u`: Move to the 'u' workspace in the current set.
        *   `$mod, I, exec, hypr-workspace-set i`: Move to the 'i' workspace in the current set.
        *   `$mod, O, exec, hypr-workspace-set o`: Move to the 'o' workspace in the current set.
        *   `$mod_SHIFT, U, exec, hypr-move-to-set u`: Move the current window to the 'u' workspace in the current set.
        *   `$mod_SHIFT, I, exec, hypr-move-to-set i`: Move the current window to the 'i' workspace in the current set.
        *   `$mod_SHIFT, O, exec, hypr-move-to-set o`: Move the current window to the 'o' workspace in the current set.
        *   `$mod, P, exec, ${variables.launcher} `: Opens the configured launcher.
        *   `$mod, D, exec, ${lib.getExe quick-menu}`: Opens the quick menu.
        *   `$mod, minus, exec, caelestia shell lock lock`: Locks the screen using caelestia.
        *   `$mod, N, exec, caelestia shell drawers toggle sidebar`: Toggles the caelestia sidebar.
        *   `$mod, Space, layoutmsg, swapwithmaster master`: Swaps the focused window with the master window.
        *   `$mod_SHIFT, Q, killactive`: Kills the active window.
        *   `$mod, F, fullscreen`: Toggles fullscreen mode for the active window.
        *   `$mod_SHIFT, F, togglefloating`: Toggles floating mode for the active window.
        *   `$mod, H, movefocus, l`: Moves focus left.
        *   `$mod, J, movefocus, d`: Moves focus down.
        *   `$mod, K, movefocus, u`: Moves focus up.
        *   `$mod, L, movefocus, r`: Moves focus right.
        *   `$mod_SHIFT, H, movewindow, l`: Moves the active window left.
        *   `$mod_SHIFT, J, movewindow, d`: Moves the active window down.
        *   `$mod_SHIFT, K, movewindow, u`: Moves the active window up.
        *   `$mod_SHIFT, L, movewindow, r`: Moves the active window right.

    *   **`bindm`**: Defines mouse bindings:
        *   `$mod,mouse:272, movewindow`: Moves the window when dragging with the left mouse button and the modifier key.
        *   `$mod,mouse:273, resizewindow`: Resizes the window when dragging with the right mouse button and the modifier key.

### Helper Functions

*   **`mkMenu`**: This function generates a `quick-menu` script using `wlr-which-key`.  It takes a `menu` list of key/description/command mappings and generates a YAML configuration file for `wlr-which-key`.  It then creates a shell script that executes `wlr-which-key` with the generated configuration file. This allows for a dynamic, key-based menu system.

### Variables (Dependencies)

This module relies on the following variables defined elsewhere in the configuration:

*   `variables.terminal`: The preferred terminal application.
*   `variables.launcher`: The preferred application launcher.
*   `config.local.caelestia.enable`: Whether caelestia is enabled.

