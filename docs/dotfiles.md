# dotfiles

This module provides a comprehensive solution for managing dotfiles and system configuration using Nix. It encompasses features for automated Git synchronization, system maintenance (garbage collection and optimization), and repository permissions management, all configurable through Nix options.

## Options

### `local.dotfiles.enable`

Type: `boolean`

Default: `false`

Description: Enables or disables the dotfiles management module. This is the master switch for all features provided by this module.

### `local.dotfiles.sync.enable`

Type: `boolean`

Default: `false`

Description: Enables automated Git synchronization for the `/etc/nixos` directory. This will automatically pull changes from the configured Git repository on a regular interval.

### `local.dotfiles.sync.interval`

Type: `string`

Default: `"30m"`

Example: `"1h"`

Description: Specifies the interval at which to pull changes from the Git repository. This uses the systemd time span format (e.g., "30m" for 30 minutes, "1h" for 1 hour).

### `local.dotfiles.maintenance.enable`

Type: `boolean`

Default: `false`

Description: Enables system maintenance features, including garbage collection and store optimization.

### `local.dotfiles.maintenance.autoUpgrade`

Type: `boolean`

Default: `false`

Description: Enables automated system upgrades.  If enabled, the system will automatically pull from the configured flake and apply upgrades.

### `local.dotfiles.maintenance.upgradeFlake`

Type: `string`

Default: `"git+http://${config.local.hosts.onix}:3002/xiro/dotfiles.nix.git"`

Example: `"github:user/dotfiles"`

Description: The Flake URL to use for system auto-upgrades. This should point to a Nix Flake containing your system configuration.  This allows you to automatically keep your system up to date.

### `local.dotfiles.repo.enable`

Type: `boolean`

Default: `false`

Description: Enables management of the `/etc/nixos` repository permissions and symlinks.  If enabled, appropriate group ownership and permissions will be set on the `/etc/nixos` directory.

### `local.dotfiles.repo.editorGroup`

Type: `string`

Default: `"wheel"`

Example: `"users"`

Description: The group that should have write access to the `/etc/nixos` repository.  This option controls the group ownership of the `/etc/nixos` directory.

