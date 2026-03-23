```markdown
# waybar

This Nix module provides a comprehensive configuration for the Waybar, a highly customizable and lightweight status bar for Wayland desktops. It allows you to define the modules to be displayed, their formatting, and their overall styling, integrating seamlessly with your NixOS environment.  This module aims to provide a consistent and declarative way to manage Waybar, making it easy to reproduce your configuration across different machines. It centralizes Waybar config and style management.

## Options

Here is a detailed breakdown of the available options, their types, default values, and purpose:

### `waybar.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables or disables the Waybar. When set to `true`, Waybar will be started automatically with your Wayland session.  Setting it to `false` disables the Waybar completely, preventing it from starting.

### `waybar.settings`

*   **Type:** `Attrs`
*   **Default:** `{}`
*   **Description:** A map/attribute set containing waybar settings, such as `layer`, `position` and `modules-left`. Most options in the [waybar configuration page](https://github.com/Alexays/Waybar/wiki/Configuration) should work.
    *   Note: settings defined here will override all other settings in this module. Use with caution, and prefer setting individual options for better modularity.
    *   The attributes will be serialised to waybar's `config.jsonc` file.
    *   Example:
        ```nix
        waybar.settings = {
          layer = "bottom";
          position = "bottom";
          modules-left = [ "wlr/workspaces", "clock" ];
        };
        ```

### `waybar.style`

*   **Type:** `String`
*   **Default:** `""`
*   **Description:**  A string containing custom CSS styles for Waybar. This allows you to fine-tune the appearance of your Waybar, overriding the default styles. You can use this to change colors, fonts, spacing, and other visual aspects. Use this alongside `waybar.styleFile` for cleaner configuration.

    *   Example:
        ```nix
        waybar.style = ''
          #waybar {
            background: #282a36;
            color: #f8f8f2;
          }
        '';
        ```

### `waybar.styleFile`

*   **Type:** `Null or Path`
*   **Default:** `null`
*   **Description:**  Specifies a path to a CSS file containing styles for Waybar. This is the preferred way to manage larger style configurations, as it keeps your Nix configuration cleaner and more organized.  The contents of the file will be included in the Waybar's CSS configuration.

    *   Example:
        ```nix
        waybar.styleFile = ./waybar.css;
        ```

### `waybar.modules-*`

*   **Type:** `List of Strings`
*   **Default:** `[]` (for each module area like `left`, `center`, `right`)
*   **Description:**  Lists of module names to display in the specified area of the Waybar. The available areas are: `modules-left`, `modules-center`, and `modules-right`.  The order of the modules in the list determines their order in the Waybar. The available values for the list are defined by the modules available in `waybar.modules`.

    *   Example:
        ```nix
        waybar.modules-left = [ "wlr/workspaces", "cpu" ];
        waybar.modules-center = [ "clock" ];
        waybar.modules-right = [ "network", "pulseaudio", "battery" ];
        ```

### `waybar.modules`

*   **Type:** `Attrs of Attrs`
*   **Default:** `{}`
*   **Description:**  A map/attribute set containing the configuration for individual Waybar modules. This allows you to customize the behavior and appearance of each module.  Each attribute in this set represents a module name, and its value is another attribute set containing the module's configuration options. This allows for detailed module configuration, controlling their appearance and behavior in the waybar.

    *   **Common Options (within each module definition):**
        *   `format`:  (String) The format string for the module's output.  This determines how the module's data is displayed.
        *   `interval`: (Integer)  The update interval for the module, in seconds.
        *   `tooltip`: (Boolean) Whether to show a tooltip when hovering over the module.
        *   `on-click`: (String)  A command to execute when the module is clicked.
        *   `on-right-click`: (String)  A command to execute when the module is right-clicked.
        *   `on-scroll-up`: (String)  A command to execute when the module is scrolled up on.
        *   `on-scroll-down`: (String)  A command to execute when the module is scrolled down on.

    *   Example:
        ```nix
        waybar.modules = {
          "clock" = {
            format = "{:%Y-%m-%d %H:%M:%S}";
            interval = 1;
            tooltip = true;
          };
          "cpu" = {
            format = "CPU: {usage:.1f}%";
            interval = 5;
            on-click = "alacritty -e htop";
          };
          "memory" = {
            format = "RAM: {used:G}/{total:G}G ({percentage:.0f}%)";
            interval = 10;
          };
          "network" = {
            format = "{ifname}: {ipaddr}/{cidr} ";
            tooltip = true;
          };
          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = " Muted";
            on-click = "pavucontrol";
            "format-icons" = [ "", "", "" ];
          };
          "battery" = {
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            "format-icons" = [ "", "", "", "", "" ];
          };
          "wlr/workspaces" = {
            disable-scroll = true; # disable workspace switching by scrolling to prevent accidents
          };
        };
        ```

### `waybar.package`

*   **Type:** `Package`
*   **Default:** `pkgs.waybar`
*   **Description:**  Specifies the Waybar package to use. This allows you to use a custom build of Waybar or a specific version.  You can override this to use a different package source, such as a git checkout or a modified derivation.

    *   Example:
        ```nix
        waybar.package = pkgs.waybar.overrideAttrs (old: {
          patches = [ ./my-waybar-patch.patch ];
        });
        ```

### `waybar.systemdIntegration`

*   **Type:** `Boolean`
*   **Default:** `true`
*   **Description:** Controls whether Waybar is started and managed as a systemd user service. When enabled, Waybar will be launched automatically when you log in, and systemd will handle its restart in case of crashes. This option improves the reliability and stability of your Waybar instance.  Setting it to `false` requires you to manually manage Waybar's startup, typically through your window manager's autostart configuration.

### `waybar.configFile`

*   **Type:** `Null or Path`
*   **Default:** `null`
*   **Description:** Specifies the path to a custom Waybar configuration file (`config.jsonc`). If set, the module's configuration will be ignored, and the specified file will be used directly.  This provides maximum flexibility but requires you to manage the entire Waybar configuration manually.  If this is set, the `waybar.modules`, `waybar.modules-*` and `waybar.settings` options will not have any effect.

    *   Example:
        ```nix
        waybar.configFile = ./my-waybar-config.jsonc;
        ```

### `waybar.extraConfig`
*   **Type:** `Attrs`
*   **Default:** `{}`
*   **Description:** Allows adding extra configuration options to the generated `config.jsonc` file. This is useful for including features not directly supported by the module's options, such as custom module configurations. These config values are merged directly into the generated Waybar configuration. This is useful for adding additional settings that are not supported by the module.

```

