```markdown
# backup-manager

This Nix module configures Borg Backup to automatically backup specified paths on a daily basis. It automatically discovers user home directories and common subfolders (Projects, Documents, Pictures, Videos, .ssh), and allows you to specify additional paths and exclusion patterns. It also configures a systemd service that runs the backup job, ensuring that the backup location is a mount point before running.

## Options

### `local.backup-manager.enable`

Type: boolean

Default: `false`

Description: Enables the backup-manager module.

### `local.backup-manager.backupLocation`

Type: string

Default: `""`

Example: `"/media/Backups"`

Description: The base path for the Borg Backup repository. This **must** be a mounted filesystem.  This is where the backups will be stored. A subfolder will be created within this path named after the host machine.

### `local.backup-manager.paths`

Type: list of strings

Default: `[ ]`

Example: `[ "/etc/nixos" "/var/lib/important" ]`

Description: A list of additional paths to backup, beyond the automatically discovered user folders (Projects, Documents, Pictures, Videos, and .ssh).  These are absolute paths to directories that should be included in the borg backup.

### `local.backup-manager.exclude`

Type: list of strings

Default: `[ ]`

Example: `[ "*/node_modules" "*/target" "*/.cache" "*.tmp" ]`

Description: A list of glob patterns to exclude from backups. These patterns are applied to all paths being backed up.  Using globs here prevents matching these folders or filetypes.
```
