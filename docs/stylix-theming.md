```markdown
# stylix-theming

This Nix module provides configurations for fonts and stylix theming. It allows enabling a collection of Nerd Fonts, Noto fonts, and emoji support, as well as configuring stylix for automatic theming based on a wallpaper.

## Options

### `local.fonts.enable`

Type: `Boolean`

Default: `false`

Description: Enables the Nerd Fonts collection including Fira Code, Noto fonts, and emoji support. When enabled, this option installs the following packages:

- `nerd-fonts.fira-code`
- `nerd-fonts.symbols-only`
- `noto-fonts`
- `noto-fonts-color-emoji`
- `twemoji-color-font`

It also enables fontconfig.

### `local.stylix.enable`

Type: `Boolean`

Default: `false`

Description: Enables the Stylix automatic theming system based on wallpaper colors.  This option provides a comprehensive configuration for stylix, including wallpaper setting, cursor customization, opacity adjustments, target applications, and font configurations.

## Detailed Configuration (When `local.stylix.enable` is true)

When `local.stylix.enable` is set to `true`, the following configurations are applied:

* **Wallpaper:**
    * A symbolic link `.wallpaper` is created in the home directory, pointing to a remotely fetched wallpaper.
    * The wallpaper URL is `https://wallpapers.onix.home/metafor.jpg`, and its SHA256 hash is `sha256-DNXaKG61TSyu5DeWVCyKmBBL1h/kF+tHjUseVY9Wl+o=`.
    *  `curl` with options `-X GET --insecure` is used to download the wallpaper.

* **Stylix Core:**
    * `stylix.enable` is set to `true`, activating the Stylix theming.
    * `stylix.image` also uses the remote wallpaper `metafor.jpg` with the same SHA256 hash.

* **Cursor:**
    * `cursor.package` is set to `pkgs.bibata-cursors`, using the Bibata Modern Ice cursor theme.
    * `cursor.name` is set to `Bibata-Modern-Ice`.
    * `cursor.size` is set to `16`.

* **Opacity:**
    * `opacity.applications` is set to `1.0`.
    * `opacity.terminal` is set to `0.95`, providing a slightly transparent terminal.
    * `opacity.desktop` is set to `1.0`.
    * `opacity.popups` is set to `0.95`.

* **Targets:**
    * `targets.nixvim.colors.enable` is set to `true`, enabling color theming for NixVim.
    * `targets.nixvim.fonts.enable` is set to `true`, enabling font theming for NixVim.
    * `targets.kitty.fonts.enable` is set to `true`, enabling font theming for Kitty.
    * `targets.kitty.colors.enable` is set to `false`. The comment indicates that color theming is handled by caelestia
    * `targets.hyprland.enable` is set to `false`. The comment indicates that color theming is handled by caelestia
    * `targets.firefox.enable` is set to `false`.
    * `targets.gtk.enable` is set to `true`.
    * `targets.qt.enable` is set to `false`.

* **Fonts:**
    * `fonts.monospace.package` is set to `pkgs.cascadia-code`, using the Cascadia Code font.
    * `fonts.monospace.name` is set to `Cascadia Code`.
    * `fonts.serif` is set to the same value as `fonts.monospace`.
    * `fonts.sansSerif` is set to the same value as `fonts.monospace`.
    * `fonts.sizes.applications` is set to `11`.
    * `fonts.sizes.terminal` is set to `10`.
    * `fonts.sizes.desktop` is set to `10`.
    * `fonts.sizes.popups` is set to `10`.
```
