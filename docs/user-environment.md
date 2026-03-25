# user-environment

This Nix module provides a comprehensive configuration for a user environment, encompassing caching, SSH, secrets management, and system variables. It aims to streamline the setup and management of a personalized and secure user workspace.

## Options

### `local.cache`

Configuration options related to caching.

#### `local.cache.enable`

(Type: `boolean`, Default: `false`)

Enables or disables the cache module.  Enabling this will install `attic-client` into the user's home directory.

#### `local.cache.watch`

(Type: `boolean`, Default: `false`)

Enables or disables the systemd service to watch the Nix store and push changes to the Attic cache. This option is only relevant if `local.cache.enable` is also enabled.

#### `local.cache.serverAddress`

(Type: `string`, Default: `"http://${config.osConfig.local.network-hosts.onix or "onix.local"}:8080/main"`)

Example: `"http://cache.example.com:8080/nixos"`

The URL of the Attic binary cache server.  It automatically uses the host defined in the `local.network-hosts` module if available, defaulting to `onix.local` if not.

#### `local.cache.publicKey`

(Type: `string`, Default: `"main:CqlQUu3twINKw6EvYnbk="`)

Example: `"cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz=="`

The public key used for verifying the cache.

### `local.ssh`

Configuration options related to SSH.

#### `local.ssh.enable`

(Type: `boolean`, Default: `false`)

Enables or disables the SSH configuration for the user. Enables `programs.ssh` and disables the default config, allowing configuration of match blocks.

#### `local.ssh.masterKeyPath`

(Type: `string`, Default: `"~/.ssh/id_ed25519"`)

Example: `"~/.ssh/id_rsa"`

The path to the SSH master private key file.  This key will be used for connecting to hosts defined in `local.ssh.hosts`.

#### `local.ssh.hosts`

(Type: `attribute set of strings`, Default: `{ Sapphire = config.osConfig.local.network-hosts.sapphire or "sapphire.local"; Ruby = config.osConfig.local.network-hosts.ruby or "ruby.local"; }`)

Example: `{ Sapphire = "sapphire.local"; Ruby = "ruby.local"; }`

A mapping of SSH host aliases to hostnames or IP addresses. It automatically uses the hosts defined in the `local.network-hosts` module if available, defaulting to `sapphire.local` and `ruby.local` if not. These are used to generate `Match` blocks in the SSH config.

### `local.secrets`

Configuration options related to secrets management.

#### `local.secrets.enable`

(Type: `boolean`, Default: `false`)

Enables or disables the secrets module, which relies on `sops`. Enabling this will install `userSops` into the user's home directory.

#### `local.secrets.sopsFile`

(Type: `path`, Default: `../../../secrets/secrets.yaml`)

Example: `../secrets/user-secrets.yaml`

The path to the encrypted YAML file containing the secrets. This file is decrypted using `sops`.  It's recommended to keep this file outside the user's home directory and under version control.

#### `local.secrets.keys`

(Type: `list of strings`, Default: `[ ]`)

Example: `[ "github/token" "api/openai" "passwords/vpn" ]`

A list of `sops` keys to automatically map to files in the `$HOME/.secrets/` directory. Each key will correspond to a file containing the decrypted secret. Ensure proper permissions are set on the `$HOME/.secrets/` directory.

### `local.variables`

Configuration options related to setting system environment variables.

#### `local.variables.enable`

(Type: `boolean`, Default: `true`)

Enables or disables the configuration of system environment variables for common tools and applications.

#### `local.variables.editor`

(Type: `string`, Default: `"nvim"`)

Example: `"vim"`

The default terminal text editor. This value will be assigned to the `EDITOR` and `VISUAL` environment variables.

#### `local.variables.guiEditor`

(Type: `string`, Default: `"neovide"`)

Example: `"code"`

The default GUI text editor. This value will be assigned to the `GUI_EDITOR` environment variable.

#### `local.variables.fileManager`

(Type: `string`, Default: `"ranger"`)

Example: `"lf"`

The default terminal file manager. This value will be assigned to the `FILEMANAGER` environment variable.

#### `local.variables.guiFileManager`

(Type: `string`, Default: `"nautilus"`)

Example: `"nautilus"`

The default GUI file manager. This value will be assigned to the `GUI_FILEMANAGER` environment variable.

#### `local.variables.terminal`

(Type: `string`, Default: `"kitty"`)

Example: `"alacritty"`

The default terminal emulator. This value will be assigned to the `TERMINAL` and `GUI_TERMINAL` environment variables.

#### `local.variables.launcher`

(Type: `string`, Default: `"rofi -show drun"`)

Example: `"wofi --show drun"`

The command for the default application launcher. This value will be assigned to the `LAUNCHER` environment variable.

#### `local.variables.wallpaper`

(Type: `string`, Default: `"hyprpaper"`)

Example: `"swaybg"`

The default wallpaper daemon or manager. This value will be assigned to the `WALLPAPER` environment variable.

#### `local.variables.browser`

(Type: `string`, Default: `"firefox"`)

Example: `"chromium"`

The default web browser. This value will be assigned to the `BROWSER` environment variable.

#### `local.variables.statusBar`

(Type: `string`, Default: `"hyprpanel"`)

Example: `"waybar"`

The default status bar or panel application. This value will be assigned to the `STATUS_BAR` environment variable.

