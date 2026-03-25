# dotfiles-sync

This Nix module provides a comprehensive solution for managing and synchronizing dotfiles within the `/etc/nixos` directory. It automates tasks such as pulling changes from a Git repository, maintaining system health through garbage collection and optimization, and managing permissions for the dotfiles repository. It's designed to streamline the management of system configurations and ensure consistency across deployments.

## Options

This module offers several configurable options to tailor its behavior to specific needs:

### `local.dotfiles-sync.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables or disables the dotfiles management module. This is the main switch to control whether any of the dotfiles-sync functionality is active.

### `local.dotfiles-sync.sync.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables automated Git synchronization for the `/etc/nixos` directory.  When enabled, a systemd timer will periodically pull changes from the configured Git repository.

### `local.dotfiles-sync.sync.interval`

*   **Type:** `types.str`
*   **Default:** `"30m"`
*   **Example:** `"1h"`
*   **Description:** Specifies how often to pull changes from the Git repository. This uses the systemd time span format (e.g., `30m`, `1h`, `2h`). It determines the interval at which the `dotfiles-sync` service will run. Shorter intervals provide more frequent updates, while longer intervals reduce network activity.

### `local.dotfiles-sync.maintenance.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables system maintenance tasks, including garbage collection (GC) and optimization of the Nix store.  This also enables the automatic upgrade functionality, if configured.

### `local.dotfiles-sync.maintenance.autoUpgrade`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables automatic pulling from git and upgrading the system.  This should be used with caution, as it can automatically apply changes to your system. It leverages the `upgradeFlake` option to determine the source of the new configuration.

### `local.dotfiles-sync.maintenance.upgradeFlake`

*   **Type:** `types.str`
*   **Default:** `"git+http://${config.local.network-hosts.onix}:3002/xiro/dotfiles.nix.git"`
*   **Example:** `"github:user/dotfiles"`
*   **Description:** Specifies the Flake URL for the system auto-upgrade.  This URL points to the Git repository containing the desired system configuration. It can be a local Git repository, a remote repository on GitHub, or any other valid Flake URL.

### `local.dotfiles-sync.repo.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables management of `/etc/nixos` permissions and symlinks.  This option allows you to control who has write access to the repository and creates symlinks to the repository in user home directories.

### `local.dotfiles-sync.repo.editorGroup`

*   **Type:** `types.str`
*   **Default:** `"wheel"`
*   **Example:** `"users"`
*   **Description:** Specifies the group that has write access to the `/etc/nixos` repository. This allows you to grant write permissions to a specific group, enabling collaborative management of the system configuration.  Ensure the specified group exists on the system.

