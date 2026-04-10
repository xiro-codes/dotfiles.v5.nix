# waybar

This Nix module configures the Waybar status bar, a highly customizable and lightweight bar for Wayland window managers. It allows you to define the modules, style, and behavior of your Waybar instance.  This module aims to provide a declarative and reproducible way to manage your Waybar configuration.

## Options

### `enable`

*   **Type:** `Boolean`
*   **Default:** `false`

Enables or disables the Waybar service. When set to `true`, the Waybar service will be started automatically when you log into your Wayland session.  When `false`, Waybar will not be launched automatically.

### `package`

*   **Type:** `Package`
*   **Default:** `pkgs.waybar`

Specifies the Waybar package to use.  This allows you to easily switch between different versions or custom builds of Waybar.  For example, you can use a specific git commit, a patched version, or a version from a different channel.

*Example:*

```nix
package = pkgs.waybar.overrideAttrs (oldAttrs: {
  version = "git";
  src = pkgs.fetchFromGitHub {
    owner = "Alexays";
    repo = "Waybar";
    rev = "some-git-commit-hash";
    sha256 = "some-sha256-hash";
  };
  buildInputs = oldAttrs.buildInputs ++ [ pkgs.libnotify ];
});
```

### `settings`

*   **Type:** `Attrs`
*   **Default:** `{}`

This option allows you to configure global Waybar settings that are not specific to individual modules. These settings are placed at the top level of the Waybar configuration file.  This is where you can define the overall appearance and behavior of your Waybar instance.  Be careful with this, as it's a direct pass through.

*Example:*

```nix
settings = {
  layer = "top";
  position = "bottom";
  height = 30;
  exclusive = true;
  passthrough-input = false;
};
```

### `modulesLeft`

*   **Type:** `List of Strings`
*   **Default:** `[]`

A list of module names to display on the left side of the Waybar.  These names correspond to the keys in the `modules` attribute set. The order of modules in this list determines the order in which they are displayed in Waybar.

*Example:*

```nix
modulesLeft = ["wlr/workspaces", "tray"];
```

### `modulesCenter`

*   **Type:** `List of Strings`
*   **Default:** `[]`

A list of module names to display in the center of the Waybar. These names correspond to the keys in the `modules` attribute set.  The order of modules in this list determines the order in which they are displayed in Waybar.

*Example:*

```nix
modulesCenter = ["clock"];
```

### `modulesRight`

*   **Type:** `List of Strings`
*   **Default:** `[]`

A list of module names to display on the right side of the Waybar. These names correspond to the keys in the `modules` attribute set.  The order of modules in this list determines the order in which they are displayed in Waybar.

*Example:*

```nix
modulesRight = ["network", "pulseaudio", "battery", "cpu", "memory"];
```

### `modules`

*   **Type:** `Attrs of Attributes`
*   **Default:** `{}`

A set of module configurations.  Each key in this attribute set represents the name of a module, and its value is an attribute set containing the configuration options for that module.  This is where you define the appearance, behavior, and data sources for each module in your Waybar.  It is *crucial* that each module used in `modulesLeft`, `modulesCenter`, and `modulesRight` has a definition here.

*Example:*

```nix
modules = {
  "wlr/workspaces" = {
    disable-scroll = true;
    all-outputs = false;
  };
  clock = {
    format = "{:%Y-%m-%d %H:%M:%S}";
  };
  network = {
    interface = "wlan0"; # Replace with your network interface
  };
  pulseaudio = {
    format = "{icon} {volume}% {format_source}";
    format-bluetooth = "{icon} {volume}% {format_source}";
    format-muted = "Muted {format_source}";
    format-source = "{volume}%";
    format-source-muted = "Muted";
    "format-icons" = [ "" "" "" ];
    on-click = "pavucontrol";
  };
  battery = {
    states = {
        good = 95;
        warning = 30;
        critical = 15;
    };
    format = "{capacity}% {icon}";
    format-charging = "{capacity}% {icon} ⚡";
    format-plugged = "{capacity}% {icon} 🔌";
    format-alt = "{time} {icon}";
    "format-icons" = [ "" "" "" ];
  };
  cpu = {
    format = "{usage}% ";
  };
  memory = {
    format = "{percentage}% ";
  };
  tray = {
    icon-size = 21;
    spacing = 10;
  };
};
```

### `style`

*   **Type:** `String`
*   **Default:** `""`

A string containing the CSS code for styling Waybar. This allows you to customize the appearance of your Waybar, including the colors, fonts, and layout of the bar and its modules.  This provides very fine-grained control over Waybar's look and feel.  The string will be directly written to `style.css`.  Consider using `builtins.readFile` to include a file's contents.

*Example:*

```nix
style = ''
  /* Global styles */
  * {
    border: none;
    border-radius: 0;
    font-family: "FiraCode Nerd Font";
    font-size: 13px;
    min-height: 0;
    color: #ebdbb2; /* Solarized Dark base0 */
  }

  window#waybar {
    background: #282828; /* Solarized Dark base03 */
    border-bottom: 3px solid #d3869b; /* Solarized Dark red */
    color: #ebdbb2; /* Solarized Dark base0 */
  }

  /* Module styles */
  #workspaces button {
    padding: 0 5px;
    background: transparent;
    color: #ebdbb2; /* Solarized Dark base0 */
  }

  #workspaces button.active {
    background: #d3869b; /* Solarized Dark red */
    color: #282828; /* Solarized Dark base03 */
  }

  #clock {
    color: #b8bb26; /* Solarized Dark yellow */
  }

  #network {
    color: #83a598; /* Solarized Dark cyan */
  }

  #pulseaudio {
    color: #83a598; /* Solarized Dark cyan */
  }

  #battery {
    color: #d3869b; /* Solarized Dark red */
  }

  #cpu {
    color: #8ec07c; /* Solarized Dark green */
  }

  #memory {
    color: #fabd2f; /* Solarized Dark orange */
  }

  #tray {
    color: #fe8019; /* Solarized Dark orange */
  }

'';
```

### `styleFile`

*   **Type:** `Path`
*   **Default:** `null`

A path to a CSS file to use for styling Waybar. If this option is set, the contents of the file will be used as the CSS code for Waybar. This is an alternative to the `style` option, allowing you to keep your CSS code in a separate file for better organization and reusability.  This option takes precedence over the `style` option if both are set.

*Example:*

```nix
styleFile = ./my-waybar.css;
```

### `extraConfig`

*   **Type:** `String`
*   **Default:** `""`

A string containing extra JSON configuration to be merged into the main Waybar configuration. This allows you to add custom configuration options that are not directly supported by this module. This should be valid JSON or JSONC.  Be very careful when using this, as invalid JSON can cause Waybar to fail to start.  This option provides the most flexibility but requires a good understanding of Waybar's configuration format.

*Example:*

```nix
extraConfig = ''
  {
    "some-custom-setting": "some-value",
    "another-setting": {
      "nested-value": 123
    }
  }
'';
```

### `onStart`

*   **Type:** `String`
*   **Default:** `""`

A shell command to execute when Waybar starts. This can be used to perform custom initialization tasks, such as setting environment variables or starting other applications.  This provides a way to customize the Waybar environment.

*Example:*

```nix
onStart = ''
  echo "Waybar started" > /tmp/waybar-start.log
'';
```

### `configFile`

*   **Type:** `Path`
*   **Default:** `null`

A path to a pre-existing waybar configuration file. If set, this option will skip any auto-generation of a config. This is useful if you want to manually manage your waybar configuration file and only use this module to start the service.  If set, most other options, like `modules`, will be ignored.  `styleFile`, `style`, and `extraConfig` *will* still be used to patch and modify the file. This is useful for overriding things such as `style` and `extraConfig` but not completely re-writing the file.

*Example:*

```nix
configFile = ./my-waybar-config.jsonc;
```
