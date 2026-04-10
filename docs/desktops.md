# desktops

This module provides a convenient way to enable and configure desktop environment support on NixOS. It handles setting up display managers, Wayland environment variables, and enabling specific desktop environments like Hyprland, Niri, and Plasma 6.  It aims to simplify the process of setting up a modern desktop environment, particularly for Wayland-based compositors.

## Options

Here's a detailed breakdown of the available options within the `local.desktops` namespace:

### `local.desktops.enable`

**Type:** boolean

**Default:** `false`

**Description:**
This option is the main switch to enable or disable desktop environment support. Setting this to `true` activates all the core desktop requirements, environment variables, and display manager configuration based on your other desktop options.

### `local.desktops.enableEnv`

**Type:** boolean

**Default:** `true`

**Description:**
Determines whether to enable Wayland-specific environment variables.  These variables are crucial for ensuring proper rendering and functionality of Wayland applications. Disabling this option may cause issues with Wayland applications if the environment variables are not set elsewhere.

Example values:

*   `true`: Enables environment variables such as `NIXOS_OZONE_WL`, `CLUTTER_BACKEND`, `GDK_BACKEND`, etc.
*   `false`: Disables the setting of Wayland environment variables.

### `local.desktops.displayManager`

**Type:** enum of "sddm", "gdm", "ly", "none", "dms"

**Default:** `"sddm"`

**Description:**
Specifies the display manager to use.  The display manager is responsible for presenting a graphical login screen and starting the desktop environment.

Possible values:

*   `"sddm"`:  Uses the SDDM display manager, configured with a custom theme.
*   `"gdm"`:  Uses the GDM display manager.
*   `"ly"`:  Uses the LY display manager.
*   `"none"`: Disables the display manager, which requires manual login via the console or SSH.
*   `"dms"`: Uses the default NixOS Display Manager Services (DMS) module.
### `local.desktops.hyprland`

**Type:** boolean

**Default:** `false`

**Description:**
Enables the Hyprland compositor. Hyprland is a dynamic tiling Wayland compositor based on wlroots. Setting this to `true` enables the `programs.hyprland` module.

### `local.desktops.niri`

**Type:** boolean

**Default:** `false`

**Description:**
Enables the Niri compositor.  Niri is another Wayland compositor option. Setting this to `true` enables the `programs.niri` module.

### `local.desktops.plasma6`

**Type:** boolean

**Default:** `false`

**Description:**
Enables the KDE Plasma 6 desktop environment.  Setting this to `true` enables the `services.desktopManager.plasma6` module. This requires plasma6 packages in scope (likely via your `nixpkgs.url` flake input pointing to a Plasma 6-enabled channel).

