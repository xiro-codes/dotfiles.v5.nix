# desktop-apps

This Nix module provides a collection of configurations and options for various desktop applications, aiming to streamline their setup and integration within a NixOS environment. It covers a range of tools, from terminal emulators and file managers to status bars and music players, allowing users to easily enable and customize their desktop experience.

## Options

Here's a detailed breakdown of the available options within the `local` namespace:

### `fish`

#### `local.fish.enable`

*   **Type:** `boolean`
*   **Default:** `true` (if Fish is the system shell, otherwise `false`)
*   **Description:** Enables Fish shell configuration. This option automatically sets up Fish with custom settings, abbreviations, and integrations if Fish is detected as the user's system shell. Specifically, it:
    *   Enables `eza` for enhanced `ls` commands.
    *   Enables `zoxide` for smart directory navigation.
    *   Installs `trash-cli` for safer file removal.
    *   Configures Fish with a minimal greeting, `zoxide` integration, VI key bindings, and sourcing `caelestia` sequences if available.
    *   Defines shell abbreviations for frequently used commands like `cd`, `find`, `ls`, `rm`, and file manager shortcuts.

### `kdeconnect`

#### `local.kdeconnect.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables KDE Connect integration. This option installs KDE Connect and configures it as a service with a tray indicator for seamless device connectivity.

### `yazi`

#### `local.yazi.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the `yazi` terminal file manager, replacing default file manager.
    *  `yazi` will be called with `yy` shell abbr.

### `kitty`

#### `local.kitty.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Kitty terminal emulator. It sets up Kitty with a custom configuration, including a window padding width of 5 pixels.

### `waybar`

#### `local.waybar.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Waybar status bar for Wayland compositors. This option configures Waybar as a systemd service, targeting the `hyprland-session.target`, and utilizes a custom settings file (`../waybar/settings.nix`) that can be further customized.  It also installs `pavucontrol`, `jq`, and `wttrbar`.

### `hyprlauncher`

#### `local.hyprlauncher.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables Hyprlauncher, a native application launcher for Hyprland.  Installs the launcher.

### `hyprpaper`

#### `local.hyprpaper.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables Hyprpaper, a wallpaper daemon for Hyprland. This option configures Hyprpaper as a service and allows preloading a list of wallpaper paths.

#### `local.hyprpaper.wallpapers`

*   **Type:** `list of paths`
*   **Default:** `[]`
*   **Example:**

    ```nix
    [ ./wallpapers/gruvbox.png ./wallpapers/catppuccin.jpg ]
    ```

*   **Description:** A list of wallpaper paths to preload for Hyprpaper. This is essential for setting the wallpaper. The first element in the list will be used as the active wallpaper.

### `mako`

#### `local.mako.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Mako notification daemon for Wayland. This option configures Mako with specific settings such as padding, border size, and border radius.

### `ranger`

#### `local.ranger.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables Ranger, a terminal-based file manager with devicons support. This option installs Ranger along with necessary utilities like `p7zip` and `unzip`, and configures Ranger with custom `rifle.conf`, `rc.conf`, and devicons plugin.

### `superfile`

#### `local.superfile.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables Superfile, a terminal-based file manager with style.  Configures Superfile's theme.

### `mpd`

#### `local.mpd.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables MPD (Music Player Daemon) with the ncmpcpp client.  It sets up MPD and integrates it with ncmpcpp.

#### `local.mpd.path`

*   **Type:** `string`
*   **Default:** `"/media/Music"`
*   **Example:** `"/home/user/Music"`
*   **Description:** The path to the music directory for MPD to serve. This determines where MPD will look for music files.

### `caelestia`

#### `local.caelestia.colorScheme`

*   **Type:** `null or string`
*   **Default:** `null`
*   **Example:** `"gruvbox"`
*   **Description:** The color scheme name for Caelestia (e.g., 'gruvbox', 'catppuccin'). If `null`, it will attempt to dynamically generate one from the wallpaper.

