```markdown
# ranger

This Nix module configures the ranger file manager, a console-based file manager with VI key bindings. It provides options to customize ranger's settings, plugins, and general behavior, making it easy to integrate ranger into your NixOS or home-manager configuration. This module ensures consistent and reproducible ranger setups across different machines.

## Options

### `programs.ranger.enable`

*   **Type:** `Boolean`
*   **Default:** `false`

Enables the ranger file manager. When set to `true`, this option installs ranger and makes it available in your environment. Setting it to `false` disables ranger.
When using home-manager this sets it up to be automatically installed into your user environment and sets up the config directory symlink.

### `programs.ranger.package`

*   **Type:** `Package`
*   **Default:** `pkgs.ranger`

Specifies the ranger package to use. This allows you to use a different version of ranger than the one provided by default. You can override this option to use a custom-built ranger package or a specific version from a channel.

**Example:**

```nix
programs.ranger.package = pkgs.ranger.overrideAttrs (oldAttrs: {
  version = "1.9.3";
  src = pkgs.fetchFromGitHub {
    owner = "ranger";
    repo = "ranger";
    rev = "v1.9.3";
    sha256 = "sha256-example"; # Replace with the actual SHA256 hash
  };
});
```

### `programs.ranger.settings`

*   **Type:** `Attrs`
*   **Default:** `{}`

Allows you to configure ranger's settings using a Nix attribute set. The keys in this attribute set correspond to the settings in ranger's `rc.conf` file. This option provides a structured way to manage ranger's configuration within your Nix configuration. The structure here acts as key-value pairs that will populate the `rc.conf`. Any options defined here take precedence over the defaults set by ranger.

**Example:**

```nix
programs.ranger.settings = {
  default_shell = "zsh"; # Set default shell
  autoupdate_interval = 30;  # Sets updates every 30 seconds
  show_hidden = true;
  use_preview_script = true;
  preview_files = true;
  preview_directories = true;

  # Custom Keybindings - will merge into existing keys, you can also override existing ones by using the same key
  keybinds = {
    normal = {
      "<C-n>" = "console new_file %s"; # Create a new file with Ctrl-n
      "<C-d>" = "console shell mkdir -p %s"; # Create a directory with Ctrl-d
      "gd" = "console cd /home/user/dev"; # go to your dev directory
    };
  };

  # Custom Commands - will merge into existing commands, you can also override existing ones by using the same command name
  commands = {
    new_file = "shell touch %s"; # creates a new file
  };
};
```

#### `programs.ranger.settings.default_shell`

*   **Type:** `String`
*   **Default:** `null`

Sets the default shell ranger will use. By default uses `$SHELL`.

#### `programs.ranger.settings.autoupdate_interval`

*   **Type:** `Integer`
*   **Default:** `null`

Sets the interval (in seconds) between automatic updates of the file listing. A value of `0` disables automatic updates.

#### `programs.ranger.settings.show_hidden`

*   **Type:** `Boolean`
*   **Default:** `null`

Determines whether hidden files and directories are displayed. Setting it to `true` shows hidden items, and `false` hides them.

#### `programs.ranger.settings.use_preview_script`

*   **Type:** `Boolean`
*   **Default:** `null`

Enables or disables the use of the preview script. When enabled, ranger uses the `scope.sh` script to generate previews of files.

#### `programs.ranger.settings.preview_files`

*   **Type:** `Boolean`
*   **Default:** `null`

Determines whether file previews are displayed. Setting it to `true` shows previews, and `false` hides them.

#### `programs.ranger.settings.preview_directories`

*   **Type:** `Boolean`
*   **Default:** `null`

Determines whether directory previews are displayed. Setting it to `true` shows previews, and `false` hides them.

#### `programs.ranger.settings.keybinds`

*   **Type:** `Attrs of Attrs of String`
*   **Default:** `{}`

Allows you to define custom keybindings for ranger. This option lets you map specific keys to ranger commands in different modes (e.g., `normal`, `console`). This will *merge* with existing keybindings so it is safe to specify a few custom ones without losing all the defaults.

**Example:**

```nix
programs.ranger.settings.keybinds = {
  normal = {
    "<C-n>" = "console new_file %s";
    "<C-d>" = "console shell mkdir -p %s";
  };
  console = {
    "<C-p>" = "paste";
  };
};
```

#### `programs.ranger.settings.commands`

*   **Type:** `Attrs of String`
*   **Default:** `{}`

Allows you to define custom commands for ranger. This option lets you create custom commands that can be executed from within ranger's console. This will *merge* with existing commands so it is safe to specify a few custom ones without losing all the defaults.

**Example:**

```nix
programs.ranger.settings.commands = {
  new_file = "shell touch %s";
  archive = "shell tar -czvf %s.tar.gz %s";
};
```

### `programs.ranger.plugins`

*   **Type:** `List of Packages`
*   **Default:** `[]`

A list of ranger plugins to install.  Plugins will be installed to `~/.config/ranger/plugins`. Each plugin is a Nix package. This is useful for extending ranger's functionality with additional features or integrations.

**Example:**

```nix
programs.ranger.plugins = [
  pkgs.python3Packages.ranger-devicons
  pkgs.python3Packages.ranger-img-preview
];
```

### `programs.ranger.rcConfExtra`

*   **Type:** `String`
*   **Default:** `""`

Allows you to add extra content to the `rc.conf` file. This option provides a way to include custom settings or configurations that are not directly supported by the `settings` option. This is useful for advanced configurations or settings that require specific formatting.
Content will be appended to the end of the generated `rc.conf`.

**Example:**

```nix
programs.ranger.rcConfExtra = ''
  # Custom status bar
  set status_bar_format 1
'';
```

### `programs.ranger.scopeShExtra`

*   **Type:** `String`
*   **Default:** `""`

Allows you to add extra content to the `scope.sh` file. This option provides a way to include custom preview scripts or configurations that are not directly supported by the `plugins` option. This is useful for adding custom preview capabilities for specific file types. Content will be appended to the end of the generated `scope.sh`.

**Example:**

```nix
programs.ranger.scopeShExtra = ''
  # Custom preview script for markdown files
  handle_extension md txt mkd mkdown markdown {
    echo "Previewing markdown file..."
    # Use a markdown previewer like mdcat
    mdcat "$@"
  }
'';
```
```
