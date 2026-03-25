# Desktops

This Nix module provides a convenient way to enable and configure various desktop environments and related settings within your NixOS system. It includes options for enabling core desktop requirements, setting up Wayland environment variables, choosing a display manager, and enabling support for specific compositors like Hyprland and Niri, as well as the KDE Plasma 6 desktop environment.

## Options

Here's a detailed breakdown of the available options within the `local.desktops` scope:

### `local.desktops.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**
    Enables the core desktop environment support. This is the primary switch that activates the module's functionality, including setting up essential system packages and potentially configuring a display manager.  If this option is set to `true`, the module proceeds to configure other options, like the display manager, environment variables, and specific desktop environments. If `false`, most of the module's configuration is skipped.  It is the foundational setting upon which all others depend.

### `local.desktops.enableEnv`

*   **Type:** `boolean`
*   **Default:** `true`
*   **Description:**
    Enables the setting of Wayland-specific environment variables. These variables are crucial for applications to function correctly within a Wayland environment.  These variables configure application backends and display configurations to integrate smoothly with the Wayland display server. Disabling this might lead to compatibility issues with Wayland-native applications. When enabled, the module sets variables like `NIXOS_OZONE_WL`, `CLUTTER_BACKEND`, `GDK_BACKEND`, `MOZ_ENABLE_WAYLAND` and others.

### `local.desktops.displayManager`

*   **Type:** `enum [ "sddm" "gdm" "ly" "none" "dms" ]`
*   **Default:** `"dms"`
*   **Description:**
    Specifies the display manager to use.  The display manager handles the login process and starts the desktop environment.

    *   `"sddm"`:  Enables the Simple Desktop Display Manager (SDDM), a modern and highly customizable display manager. Enables Wayland support for SDDM.
    *   `"gdm"`: Enables the GNOME Display Manager (GDM), the default display manager for GNOME-based systems.
    *   `"ly"`: Enables Ly, a lightweight TTY-based display manager.
    *   `"none"`: Disables any display manager.  This is useful for headless systems or when managing display management through other means, such as a custom script.
    *   `"dms"`: Enables `dms-greeter` display manager, configured to use Hyprland as the compositor.  This is typically used in conjunction with enabling Hyprland in the module.

### `local.desktops.hyprland`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**
    Enables the Hyprland compositor. Hyprland is a dynamic tiling Wayland compositor based on wlroots, known for its customization options. This option ensures Hyprland is installed and configured to run. Uses a flake input to find the package.

### `local.desktops.niri`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**
    Enables the Niri compositor. This option installs and configures the Niri compositor, providing an alternative desktop environment.

### `local.desktops.plasma6`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**
    Enables the KDE Plasma 6 desktop environment. This option configures Plasma 6 as the active desktop environment, ensuring all necessary packages are installed and configured.

