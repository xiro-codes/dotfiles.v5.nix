# desktop-apps

This Nix module provides a collection of configurations and options for various desktop applications, enhancing the user experience with customized settings and integrations. It allows users to easily enable and configure programs like fish, kitty, waybar, hyprpaper, ranger, mpd, and others.  The module uses `mkEnableOption` extensively to simplify enabling or disabling applications. It integrates with system services like `hyprpaper`, `kdeconnect`, `mako`, and `mpd`, and customizes application settings via NixOS options.

## Options

Here is a detailed breakdown of the available options:

### `local.fish`

#### `local.fish.enable`

*   **Type:** `Boolean`
*   **Default:** Determined by if the system shell is fish (`isDefaultShell`).
*   **Description:** Enables fish shell configuration if it is the system shell.  This includes setting up `eza`, `zoxide`, `trash-cli`, `fastfetch`, shell abbreviations, and interactive shell initialization. If set to true, the module will configure fish with the specified settings.

### `local.kdeconnect`

#### `local.kdeconnect.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables kdeconnect and its associated services. When enabled, it installs the `kdeconnect-kde` package and configures the `kdeconnect` service to run with an indicator icon.

### `local.yazi`

#### `local.yazi.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables yazi, a terminal file manager. When enabled, it installs and configures the yazi package, enabling fish integration and defining a shell wrapper alias `yy`. Also, the file manager variable will be set to `yazi`.

### `local.kitty`

#### `local.kitty.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables the Kitty terminal emulator with a custom configuration. When enabled, it installs and configures Kitty, adding extra configuration options such as `window_padding_width`. The terminal variable will also be set to kitty.

### `local.waybar`

#### `local.waybar.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables the Waybar status bar for Wayland compositors. When enabled, it installs necessary packages like `pavucontrol`, `jq`, and `wttrbar`, configures the Waybar service, and enables it as a systemd target under the `hyprland-session.target`. Also uses a custom `settings.nix` file for waybar.

### `local.hyprlauncher`

#### `local.hyprlauncher.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables Hyprlauncher, the native Hyprland application launcher. When enabled, it installs the `hyprlauncher` package and sets the local variable `launcher` to "hyprlauncher".

### `local.hyprpaper`

#### `local.hyprpaper.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables Hyprpaper, the native Hyprland wallpaper daemon. When enabled, it configures the `hyprpaper` service to preload and set wallpapers specified in `local.hyprpaper.wallpapers`.  Also sets the variable `wallpaper` to `hyprpaper`.

#### `local.hyprpaper.wallpapers`

*   **Type:** `List of Paths`
*   **Default:** `[ ]`
*   **Example:** `[ ~/.wallpaper ]`
*   **Description:** A list of wallpaper paths to preload for Hyprpaper. This list defines which wallpapers Hyprpaper will manage and display. The first wallpaper in the list will be actively set.

### `local.mako`

#### `local.mako.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables the Mako notification daemon for Wayland. When enabled, it configures the `mako` service with custom padding, border size, and border radius settings.

### `local.ranger`

#### `local.ranger.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables the Ranger terminal-based file manager with devicons support. When enabled, it installs Ranger, p7zip, and unzip, sets the fileManager variable to ranger, and configures Ranger's rifle.conf, rc.conf, and ranger_devicons.

### `local.superfile`

#### `local.superfile.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables the Superfile terminal-based file manager. When enabled, it installs and configures superfile with a gruvbox theme.

### `local.mpd`

#### `local.mpd.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables MPD (Music Player Daemon) with ncmpcpp client. When enabled, it configures MPD with a music directory and custom audio outputs (pipewire and fifo for visualizer support), configures ncmpcpp with visualizer support, key bindings, and notification settings.

#### `local.mpd.path`

*   **Type:** `String`
*   **Default:** `"/media/Music"`
*   **Example:** `"/home/user/Music"`
*   **Description:** Path to the music directory for MPD to serve. This specifies where MPD should look for music files.

### `local.caelestia`

#### `local.caelestia.colorScheme`

*   **Type:** `Null or String`
*   **Default:** `null`
*   **Example:** `"gruvbox"`
*   **Description:** Color scheme name for Caelestia (e.g., 'gruvbox', 'catppuccin'). If `null`, Caelestia uses dynamic wallpaper colors. Provides a mechanism to set the desired color scheme for the `caelestia` program.

