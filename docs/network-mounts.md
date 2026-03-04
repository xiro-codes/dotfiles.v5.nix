# network-mounts

This module simplifies the management of SMB/CIFS network shares by automatically creating systemd mount and automount units. It allows you to define a list of shares with their respective mount points, authentication details (using SOPS secrets), and various options for customization. This ensures that your network shares are mounted on demand and are readily available without manual intervention.

## Options

### `local.network-mounts.enable`

  Type: boolean

  Default: `false`

  Description: Enables or disables the configuration of Samba mounts from Onix.

### `local.network-mounts.noAuth`

  Type: boolean

  Default: `false`

  Description: Specifies whether to mount shares as guest without credentials. If set to `true`, the `credentials` option in the mount configuration will be omitted.  If set to false, the sops secret name is required.

### `local.network-mounts.secretName`

  Type: string

  Default: `"onix_creds"`

  Example: `"smb_credentials"`

  Description: The name of the SOPS secret containing the SMB credentials. The secret should be in the format `username=xxx` and `password=xxx`.  This is required if the noAuth option is false.

### `local.network-mounts.serverIp`

  Type: string

  Default: `config.local.hosts.onix`

  Example: `"192.168.1.100"`

  Description: The IP address or hostname of the SMB/CIFS server.  This module uses this to generate the mount path.

### `local.network-mounts.mounts`

  Type: list of submodules

  Default: `[]`

  Example:
  ```nix
  [
    { shareName = "Media"; localPath = "/media/Media"; }
    { shareName = "Backups"; localPath = "/media/Backups"; noShow = true; }
  ]
  ```

  Description: A list of SMB/CIFS shares to mount automatically with systemd automount. Each element in the list is a submodule with the following options:

  - **`shareName`**
    - Type: string
    - Example: `"Media"`
    - Description: The name of the share on the SMB server.  This is the server side of the mount.
  - **`localPath`**
    - Type: string
    - Example: `"/media/Media"`
    - Description: The local mount point path. Common locations include `/media/`, `/mnt/`, or `/run/media/`.
  - **`noShow`**
    - Type: boolean
    - Default: `false`
    - Description: Whether to hide this mount from the file manager. This is achieved using the `x-gvfs-hide` option. Setting this to `true` will prevent the share from being displayed in graphical file managers.
  - **`noAuth`**
    - Type: boolean
    - Default: `false`
    - Description: Whether to mount as a guest without authentication. If `true`, the `guest` option will be used in the mount configuration, skipping credential usage.
  - **`options`**
    - Type: list of strings
    - Default: `[]`
    - Example: `[ "ro" "vers=3.0" ]`
    - Description: Additional mount options to append to the default options. These options are concatenated with the base options using a comma as a separator.  This is how you define things like the SMB version.
