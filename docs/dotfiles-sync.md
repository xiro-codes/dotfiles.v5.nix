# dotfiles-sync

This Nix module provides comprehensive dotfiles management for a NixOS system, focusing on automated Git synchronization, system maintenance, and repository permissions. It's designed to keep your `/etc/nixos` directory up-to-date, perform system optimization, and manage user access to configuration files.

## Options

This module exposes the following options within the `local.dotfiles-sync` scope:

### `local.dotfiles-sync.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables or disables the entire dotfiles management module. This is the main switch to activate the functionalities defined in this module.

### `local.dotfiles-sync.sync.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables automated Git synchronization for the `/etc/nixos` directory. When enabled, a systemd service and timer will be configured to periodically pull changes from a Git repository.

### `local.dotfiles-sync.sync.interval`

*   **Type:** `types.str`
*   **Default:** `"30m"`
*   **Example:** `"1h"`
*   **Description:** Specifies how often to pull changes from the Git repository. The value must be a string representing a time span in a format understood by systemd (e.g., "30m" for 30 minutes, "1h" for 1 hour, "2h" for 2 hours).

### `local.dotfiles-sync.maintenance.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables system maintenance tasks, including garbage collection and optimization.  These settings can reduce disk space usage and improve system performance.

### `local.dotfiles-sync.maintenance.autoUpgrade`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Determines whether to automatically pull from Git and upgrade the system. If enabled, the system will periodically check for and apply updates from the specified Flake URL. Requires `local.dotfiles-sync.maintenance.enable` to also be true.

### `local.dotfiles-sync.maintenance.upgradeFlake`

*   **Type:** `types.str`
*   **Default:** `"git+http://${config.local.network-hosts.onix}:3002/xiro/dotfiles.nix.git"`
*   **Example:** `"github:user/dotfiles"`
*   **Description:**  The Flake URL used for system auto-upgrade. This specifies the source of the system configuration, allowing you to manage your NixOS configuration in a Git repository and automatically deploy changes. Can be a local git repository or a remote one.

### `local.dotfiles-sync.repo.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables management of `/etc/nixos` permissions and symlinks. When enabled, the module will set appropriate group ownership and permissions on the `/etc/nixos` directory, and create symlinks in user home directories pointing to the configuration.

### `local.dotfiles-sync.repo.editorGroup`

*   **Type:** `types.str`
*   **Default:** `"wheel"`
*   **Example:** `"users"`
*   **Description:** The group that has write access to the `/etc/nixos` repository. This allows you to control which users or groups are authorized to modify the system configuration files.  It's crucial for maintaining system integrity and security.

