# user-environment

This Nix module provides a comprehensive set of configurations for the user environment, including settings for caching, SSH, secrets management with SOPS, and common system variables. It allows users to easily manage their environment configurations, SSH keys, and sensitive information through a declarative Nix configuration.

## Options

### `local.cache.enable`

Type: `boolean`

Default: `false`

Description: Enables the cache module, which configures the system to use an Attic binary cache server. When enabled, the `attic-client` package is added to the user's home packages.

### `local.cache.watch`

Type: `boolean`

Default: `false`

Description: Enables a systemd service to watch the Nix store and push changes to the Attic cache server. Requires `local.cache.enable` to be enabled.

### `local.cache.serverAddress`

Type: `string`

Default: `"http://${config.osConfig.local.network-hosts.onix or "onix.local"}:8080/main"`

Example: `"http://cache.example.com:8080/nixos"`

Description: The URL of the Attic binary cache server. It automatically uses the host from the `local.network-hosts` module if available, defaulting to `onix.local`.

### `local.cache.publicKey`

Type: `string`

Default: `"main:CqlQUu3twINKw6EvYnbk="`

Example: `"cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz=="`

Description: The public key used for verifying the Attic cache. This key is crucial for ensuring the integrity of packages retrieved from the cache.

### `local.ssh.enable`

Type: `boolean`

Default: `false`

Description: Enables SSH configuration for the user. When enabled, it configures SSH settings based on the module options.

### `local.ssh.masterKeyPath`

Type: `string`

Default: `"~/.ssh/id_ed25519"`

Example: `"~/.ssh/id_rsa"`

Description: The path to the user's SSH master private key file. This key is used for authentication with SSH servers.

### `local.ssh.hosts`

Type: `attribute set of strings`

Default:

```nix
{
  Sapphire = config.osConfig.local.network-hosts.sapphire or "sapphire.local";
  Ruby = config.osConfig.local.network-hosts.ruby or "ruby.local";
  Onix = config.osConfig.local.network-hosts.onix or "onix.local";
  Jade = config.osConfig.local.network-hosts.jade or "jade.local";
}
```

Example:

```nix
{
  Sapphire = "sapphire.example.com";
  Ruby = "192.168.1.10";
}
```

Description: A mapping of SSH host aliases to hostnames or IP addresses.  It automatically uses hosts defined in the `local.network-hosts` module if they exist, providing convenient aliases for SSH connections.

### `local.secrets.enable`

Type: `boolean`

Default: `false`

Description: Enables the secrets module, which integrates with SOPS (Secrets OPerationS) to manage encrypted secrets.

### `local.secrets.sopsFile`

Type: `path`

Default: `../../../secrets/secrets.yaml`

Example: `../secrets/user-secrets.yaml`

Description: The path to the encrypted YAML file containing secrets managed by SOPS.

### `local.secrets.keys`

Type: `list of strings`

Default: `[ ]`

Example: `[ "github/token" "api/openai" "passwords/vpn" ]`

Description: A list of SOPS keys to automatically map to files in the `$HOME/.secrets/` directory. Each key corresponds to a secret stored in the SOPS file.

### `local.variables.enable`

Type: `boolean`

Default: `true`

Description: Enables setting system environment variables for common tools and applications.

### `local.variables.editor`

Type: `string`

Default: `"nvim"`

Example: `"vim"`

Description: The default terminal text editor.  This variable is used for setting both `EDITOR` and `VISUAL` environment variables.

### `local.variables.guiEditor`

Type: `string`

Default: `"neovide"`

Example: `"code"`

Description: The default GUI text editor. This variable is used for setting the `GUI_EDITOR` environment variable.

### `local.variables.fileManager`

Type: `string`

Default: `"ranger"`

Example: `"lf"`

Description: The default terminal file manager. This variable is used for setting the `FILEMANAGER` environment variable.

### `local.variables.guiFileManager`

Type: `string`

Default: `"nautilus"`

Example: `"thunar"`

Description: The default GUI file manager. This variable is used for setting the `GUI_FILEMANAGER` environment variable.

### `local.variables.terminal`

Type: `string`

Default: `"kitty"`

Example: `"alacritty"`

Description: The default terminal emulator. This variable is used for setting both `TERMINAL` and `GUI_TERMINAL` environment variables.

### `local.variables.launcher`

Type: `string`

Default: `"rofi -show drun"`

Example: `"wofi --show drun"`

Description: The command to launch the default application launcher.  This is used for setting the `LAUNCHER` environment variable.

### `local.variables.wallpaper`

Type: `string`

Default: `"hyprpaper"`

Example: `"swaybg"`

Description: The default wallpaper daemon or manager. This is used for setting the `WALLPAPER` environment variable.

### `local.variables.browser`

Type: `string`

Default: `"firefox"`

Example: `"chromium"`

Description: The default web browser. This is used for setting the `BROWSER` environment variable.

### `local.variables.statusBar`

Type: `string`

Default: `"hyprpanel"`

Example: `"waybar"`

Description: The default status bar or panel application. This is used for setting the `STATUS_BAR` environment variable.

