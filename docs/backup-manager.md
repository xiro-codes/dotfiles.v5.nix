# Backup Manager

The `backup-manager` module configures **BorgBackup** to automatically backup system and user data.

## Configuration

Enable the module and specify the backup location (must be a mounted path):

```nix
local.backup-manager = {
  enable = true;
  backupLocation = "/media/Backups";
  
  # Optional: Add extra system paths
  paths = [ "/etc/nixos" "/var/lib/important" ];
  
  # Optional: Exclude patterns
  exclude = [ "*/node_modules" "*/target" ];
};
```

## Features

- **Auto-Discovery**: Automatically backs up standard user folders:
  - `Projects`
  - `Documents`
  - `Pictures`
  - `Videos`
  - `.ssh`
- **Schedule**: Runs daily.
- **Pruning**: Keeps 7 daily and 4 weekly backups.
- **Manifest**: Generates `/etc/backup-manifest.txt` listing all backed-up paths.

## Usage

Check backup status:
```bash
sudo systemctl status borgbackup-job-onix-local
```

List archives:
```bash
sudo borg list /media/Backups/$(hostname)
```
