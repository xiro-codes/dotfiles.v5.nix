# stylix-theming

This module provides configuration options for fonts and stylix theming. It allows enabling nerd fonts, setting up a `.wallpaper` symlink in the home directory, and configuring stylix with a remote wallpaper.  It aims to provide a cohesive and personalized user experience across different applications.  It is designed to seamlessly integrate with other NixOS modules and tools.

## Options

### `local.fonts.enable`

Type: boolean

Default: `false`

Description: Enables a Nerd Fonts collection, including Fira Code, Noto fonts, and emoji support. When enabled, this option installs the necessary font packages and enables fontconfig.

### `local.stylix.enable`

Type: boolean

Default: `false`

Description: Enables the stylix automatic theming system based on wallpaper colors. This option configures stylix to generate themes based on a specified image, and applies those themes across various applications, including NixVim, Kitty, Zen Browser, GTK.

## Details and Usage

This module manages font configuration and integrates the `stylix` theming engine to provide a uniform look and feel across your system. Enabling `local.fonts.enable` installs a suite of popular Nerd Fonts, providing icons and glyphs for various applications, especially terminals and code editors. Enabling `local.stylix.enable` leverages the color palette derived from a specified wallpaper to theme compatible applications.

### Fonts (`local.fonts.enable`)

When enabled, this option:

*   Installs `nerd-fonts.fira-code`, `nerd-fonts.symbols-only`, `noto-fonts`, `noto-fonts-color-emoji`, and `twemoji-color-font`.
*   Enables `fonts.fontconfig.enable` to manage font configuration.

This ensures a broad range of glyphs and characters are available, enhancing readability and providing visual cues in your workflow.

### Stylix Theming (`local.stylix.enable`)

When enabled, this option does the following:

1.  **Wallpaper Symlink:** Creates a `.wallpaper` symlink in the home directory, pointing to a remote wallpaper image fetched from `https://wallpapers.onix.home`. This symlink is used by some applications to automatically adapt their theme to the wallpaper.

2.  **Stylix Configuration:** Sets up the main `stylix` configuration, including:

    *   `enable = true`: Enables stylix.
    *   `image`: Specifies the wallpaper image using the `remoteWallpaper` function.  It fetches the wallpaper from the same remote URL.
    *   `cursor`: Configures the mouse cursor using `bibata-cursors`. The cursor theme is set to "Bibata-Modern-Ice" with a size of 16 pixels.
    *   `opacity`: Adjusts the opacity of various window types. This includes applications, terminal, desktop, and popups.
    *   `targets`: Specifies which applications stylix should theme. This configuration enables theming for NixVim, Kitty (fonts only since colors are handled by caelestia), Zen Browser, and GTK.  It disables theming for Hyprland, Firefox, and Qt, deferring the management of these to other applications/configurations.
    *   `fonts`: Configures the default font families and sizes. The monospace font is set to "Cascadia Code". The serif and sans-serif fonts are configured to inherit the same font as the monospace.  Different sizes are configured for applications, terminal, desktop, and popups, allowing customization of font sizes across the system.

### `remoteWallpaper` Function

This is a utility function defined within the module that is used to fetch wallpapers from a remote URL. It uses `pkgs.fetchurl` to download the image and specifies the URL and SHA256 hash for verification. It also includes `curlOptsList` to configure curl to use insecure mode (likely because the server uses a self-signed certificate).

### Example Usage
```nix
{
  imports = [
    ./path/to/this/module.nix
  ];

  local = {
    fonts.enable = true;
    stylix.enable = true;
  };
}
```

This snippet enables both the Nerd Fonts collection and the Stylix theming.  This will download and install the required font packages and configure Stylix based on the remote wallpaper defined in the module.

