# backup-manager

This Nix module simplifies the configuration of BorgBackup for backing up user data and system configurations. It automatically discovers user home directories and common subfolders (Projects, Documents, Pictures, Videos, .ssh) for inclusion in the backup, and allows you to specify additional paths and exclude patterns. This makes it easy to set up a comprehensive backup solution with minimal manual configuration. The module creates a borgbackup job named `onix-local` that will backup the `finalPaths` to a borg repository. The paths are automatically generated from users home directories and common subfolders and can be extended with custom paths.

## Options

### `local.backup-manager.enable`

Type: `boolean`

Default: `false`

Description: Enables or disables the backup-manager module. When enabled, it configures a BorgBackup job and related systemd service.

### `local.backup-manager.backupLocation`

Type: `string`

Default: `""` (empty string)

Example: `"/media/Backups"`

Description: The base path for the BorgBackup repository. This should be a mounted filesystem where your backups will be stored.  Crucially, this directory *must* be a mountpoint, as the systemd service will check for it and require mounts for it.

### `local.backup-manager.paths`

Type: `list of strings`

Default: `[]` (empty list)

Example: `[ "/etc/nixos" "/var/lib/important" ]`

Description: A list of additional paths to include in the backup. These paths are added to the automatically discovered user home directory subfolders.  Useful for backing up system-level configurations or other important data outside of the user's home directories. The paths should be absolute.

### `local.backup-manager.exclude`

Type: `list of strings`

Default: `[]` (empty list)

Example: `[ "*/node_modules" "*/target" "*/.cache" "*.tmp" ]`

Description: A list of glob patterns to exclude from the backups. This allows you to exclude unnecessary or large files and directories, such as node_modules, target directories, cache directories, and temporary files. These exclude patterns will be passed directly to BorgBackup.
