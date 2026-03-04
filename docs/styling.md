# Local Module

This Nix module provides configurations for fonts and Stylix theming.  It offers options to easily enable a collection of Nerd Fonts, Noto fonts, and emoji support, as well as to enable and configure Stylix, an automatic theming system based on wallpaper colors.

## Options

### `local.fonts.enable`

*   **Type:** `boolean`
*   **Default:** `false`

Enables a collection of Nerd Fonts including Fira Code, symbols-only fonts, Noto fonts (regular and color emoji), and Twemoji color font. When enabled, it also configures `fontconfig`.

### `local.stylix.enable`

*   **Type:** `boolean`
*   **Default:** `false`

Enables the Stylix automatic theming system based on wallpaper colors.  This option enables comprehensive theming across various applications and environments.

## Configuration Details

When `local.fonts.enable` is set to `true`, the following packages are installed into `home.packages`:

*   `nerd-fonts.fira-code`
*   `nerd-fonts.symbols-only`
*   `noto-fonts`
*   `noto-fonts-color-emoji`
*   `twemoji-color-font`

`fonts.fontconfig.enable` is also set to `true` to enable font configuration.

When `local.stylix.enable` is set to `true`, the following configuration is applied:

*   **Wallpaper Symlink:** A symbolic link `.wallpaper` is created in the home directory, pointing to `./Wallpaper8.jpg`.  This allows Stylix to use this image for theming.

*   **Stylix Configuration:**

    *   `enable = true;`: Enables the Stylix module.
    *   `image = ./wallpaper.jpg;`: Sets the wallpaper image for theme generation.
    *   `cursor = { ... };`: Configures the cursor theme:
        *   `package = pkgs.bibata-cursors;`: Specifies the Bibata cursors package.
        *   `name = "Bibata-Modern-Ice";`: Sets the cursor theme name.
        *   `size = 16;`: Sets the cursor size.
    *   `opacity = { ... };`: Sets opacity levels for different application types:
        *   `applications = 1.0;`
        *   `terminal = 0.95;`
        *   `desktop = 1.0;`
        *   `popups = 0.95;`
    *   `targets = { ... };`: Defines which applications and environments should be themed by Stylix:
        *   `nixvim.colors.enable = true;`
        *   `nixvim.fonts.enable = true;`
        *   `kitty.fonts.enable = true;`
        *   `kitty.colors.enable = false;`  (Let `caelestia` handle colors, presumably another module)
        *   `hyprland.enable = false;` (Let `caelestia` handle hyprland colors, presumably another module)
        *   `firefox.enable = false;`
        *   `gtk.enable = true;`
        *   `qt.enable = false;`
    *   `fonts = { ... };`: Configures font settings:
        *   `monospace = { ... };`: Sets the monospace font:
            *   `package = pkgs.cascadia-code;`: Specifies the Cascadia Code font package.
            *   `name = "Cascadia Code";`: Sets the font name.
        *   `serif = config.stylix.fonts.monospace;`:  Sets the serif font to the same as the monospace font.
        *   `sansSerif = config.stylix.fonts.monospace;`: Sets the sans-serif font to the same as the monospace font.
        *   `sizes = { ... };`: Sets font sizes for different application types:
            *   `applications = 11;`
            *   `terminal = 10;`
            *   `desktop = 10;`
            *   `popups = 10;`

