# Client Profile

The Client profile is intended for systems that rely on the central NAS (Onix) for storage and backups.

## Configuration Details

- **Location**: `systems/profiles/client.nix`
- **Features**:
    - **Backups**: Automatically configures `backup-manager` to store backups on the NAS.
    - **Network Mounts**: Configures NFS/SMB mounts for common shares (Media, Storage, Music, etc.).
    - **Maintenance**: Enables automatic system upgrades.
    - **Recovery**: Enables the recovery builder for bootloader safety.
