# system-config

This Nix module provides a convenient way to configure various aspects of a user's system, including caching, SSH, secrets management (using SOPS), and environment variables. It allows you to define settings for your preferred terminal applications, editors, file managers, and more, making system configuration more manageable and reproducible.

## Options

Here's a detailed breakdown of the available options:

### `local.cache`

Configuration options for the Attic binary cache.

#### `local.cache.enable`
*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the cache module, which installs the `attic-client` package and optionally configures a systemd service to watch for changes in the Nix store and push them to the Attic cache server.

#### `local.cache.watch`
*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables a systemd user service (`attic-watch`) that automatically watches the Nix store for changes and pushes them to the Attic cache server. Requires `local.cache.enable` to be true.

#### `local.cache.serverAddress`
*   **Type:** `string`
*   **Default:** `"http://${config.osConfig.local.hosts.onix or "onix.local"}:8080/main"`
*   **Example:** `"http://cache.example.com:8080/nixos"`
*   **Description:** The URL of the Attic binary cache server.  It defaults to using the `onix` host defined in `osConfig.local.hosts` if available; otherwise, it defaults to `onix.local`. The `/main` path refers to the attic cache's name.

#### `local.cache.publicKey`
*   **Type:** `string`
*   **Default:** `"main:CqlQUu3twINKw6EvYnbk="`
*   **Example:** `"cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz=="`
*   **Description:** The public key used for verifying the authenticity of the Attic cache.  The `main:` refers to the attic cache's name.

### `local.ssh`

Configuration options for SSH.

#### `local.ssh.enable`
*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables SSH configuration for the user, including setting up `programs.ssh` and match blocks for specific hosts.

#### `local.ssh.masterKeyPath`
*   **Type:** `string`
*   **Default:** `"~/.ssh/id_ed25519"`
*   **Example:** `"~/.ssh/id_rsa"`
*   **Description:** The path to the SSH master private key file, used for authenticating to the defined hosts.

#### `local.ssh.hosts`
*   **Type:** `attribute set of strings`
*   **Default:** `{ Sapphire = config.osConfig.local.hosts.sapphire or "sapphire.local"; Ruby = config.osConfig.local.hosts.ruby or "ruby.local"; }`
*   **Example:** `{ Sapphire = "sapphire.local"; Ruby = "ruby.local"; }`
*   **Description:** A mapping of SSH host aliases to hostnames or IP addresses. These aliases can be used in the command line instead of the full hostname. It automatically uses hosts from the `osConfig.local.hosts` module if available.

### `local.secrets`

Configuration options for managing secrets with SOPS.

#### `local.secrets.enable`
*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the secrets module, which installs `user-sops` and configures SOPS to decrypt secrets into the user's home directory.

#### `local.secrets.sopsFile`
*   **Type:** `path`
*   **Default:** `../../../secrets/secrets.yaml`
*   **Example:** `../secrets/user-secrets.yaml`
*   **Description:** The path to the encrypted YAML file containing the secrets managed by SOPS.  Relative paths are generally used.

#### `local.secrets.keys`
*   **Type:** `list of strings`
*   **Default:** `[ ]`
*   **Example:** `[ "github/token" "api/openai" "passwords/vpn" ]`
*   **Description:** A list of SOPS keys to automatically map to files in `$HOME/.secrets/`. Each key corresponds to a top-level field in the SOPS-encrypted file.

### `local.variables`

Configuration options for setting system environment variables.

#### `local.variables.enable`
*   **Type:** `boolean`
*   **Default:** `true`
*   **Description:** Enables setting system environment variables for common tools and applications.

#### `local.variables.editor`
*   **Type:** `string`
*   **Default:** `"nvim"`
*   **Example:** `"vim"`
*   **Description:** The default terminal text editor. Sets the `EDITOR` and `VISUAL` environment variables.

#### `local.variables.guiEditor`
*   **Type:** `string`
*   **Default:** `"neovide"`
*   **Example:** `"code"`
*   **Description:** The default GUI text editor. Sets the `GUI_EDITOR` environment variable.

#### `local.variables.fileManager`
*   **Type:** `string`
*   **Default:** `"ranger"`
*   **Example:** `"lf"`
*   **Description:** The default terminal file manager. Sets the `FILEMANAGER` environment variable.

#### `local.variables.guiFileManager`
*   **Type:** `string`
*   **Default:** `"nautilus"`
*   **Example:** `"nautilus"`
*   **Description:** The default GUI file manager. Sets the `GUI_FILEMANAGER` environment variable.

#### `local.variables.terminal`
*   **Type:** `string`
*   **Default:** `"kitty"`
*   **Example:** `"alacritty"`
*   **Description:** The default terminal emulator. Sets the `TERMINAL` and `GUI_TERMINAL` environment variables.

#### `local.variables.launcher`
*   **Type:** `string`
*   **Default:** `"rofi -show drun"`
*   **Example:** `"wofi --show drun"`
*   **Description:** The default application launcher command. Sets the `LAUNCHER` environment variable.

#### `local.variables.wallpaper`
*   **Type:** `string`
*   **Default:** `"hyprpaper"`
*   **Example:** `"swaybg"`
*   **Description:** The default wallpaper daemon or manager. Sets the `WALLPAPER` environment variable.

#### `local.variables.browser`
*   **Type:** `string`
*   **Default:** `"firefox"`
*   **Example:** `"chromium"`
*   **Description:** The default web browser. Sets the `BROWSER` environment variable.

#### `local.variables.statusBar`
*   **Type:** `string`
*   **Default:** `"hyprpanel"`
*   **Example:** `"waybar"`
*   **Description:** The default status bar or panel application. Sets the `STATUS_BAR` environment variable.

