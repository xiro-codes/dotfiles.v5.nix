# network-mounts

This module provides a convenient way to automatically mount Samba (SMB/CIFS) network shares using systemd automount. It simplifies the configuration process by defining a set of options that handle authentication, permissions, and automount behavior. This module relies on `cifs-utils` and `sops` for secure credential management.  It also provides options to hide the mount from file managers like Nautilus and Dolphin.

## Options

### `local.network-mounts.enable`

Type: Boolean

Default: `false`

Description: Enables the network mounts module. When set to `true`, the configured Samba shares will be automatically mounted using systemd automount.

### `local.network-mounts.noAuth`

Type: Boolean

Default: `false`

Description:  Mount shares as guest without credentials.  If set to `true`, the shares will be mounted without authentication, meaning access will be attempted as a guest user. Note that this relies on the Samba server permitting guest access.

### `local.network-mounts.secretName`

Type: String

Default: `"onix_creds"`

Example: `"smb_credentials"`

Description:  Name of the sops secret containing SMB credentials (username=xxx and password=xxx format). This option specifies the name of the sops secret that stores the username and password for accessing the SMB shares. The secret should be formatted as `username=your_username\npassword=your_password`.  If `noAuth` is false, this option *must* point to an existing sops secret.

### `local.network-mounts.serverIp`

Type: String

Default: `config.local.network-hosts.onix`

Example: `"192.168.1.100"`

Description:  IP address or hostname of SMB/CIFS server. This is the IP address or hostname of the server hosting the SMB shares you want to mount.

### `local.network-mounts.mounts`

Type: List of Submodules

Default: `[]`

Example:
```nix
[
  { shareName = "Media"; localPath = "/media/Media"; }
  { shareName = "Backups"; localPath = "/media/Backups"; noShow = true; }
]
```

Description:  List of SMB/CIFS shares to mount automatically with systemd automount. This option defines a list of SMB/CIFS shares to be mounted. Each item in the list is a submodule with the following options:

  - **`shareName`**:
    Type: String
    Example: `"Media"`
    Description: Name of the share on the SMB server. This is the name of the shared folder on the server.

  - **`localPath`**:
    Type: String
    Example: `"/media/Media"`
    Description: Local mount point path (common locations: `/media/`, `/mnt/`, or `/run/media/`).  This is the directory on your local system where the share will be mounted. Ensure the directory exists before enabling the module.

  - **`noShow`**:
    Type: Boolean
    Default: `false`
    Description: Whether to hide this mount from file manager. If set to `true`, the mount will be hidden from graphical file managers like Nautilus or Dolphin by using the `x-gvfs-hide` mount option.

  - **`noAuth`**:
    Type: Boolean
    Default: `false`
    Description: Whether to mount as guest without authentication. If set to `true`, this specific mount will attempt to connect as a guest user, overriding the global `noAuth` option.

  - **`options`**:
    Type: List of Strings
    Default: `[]`
    Example: `[ "ro" "vers=3.0" ]`
    Description: Additional mount options to append to defaults. This allows you to specify additional mount options to be passed to the `mount` command. Common options include `ro` (read-only), `vers=3.0` (SMB version), `uid=1000` (user ID), and `gid=100` (group ID).  These are appended to a base set of options that ensure correct behaviour:
      - `noperm`:  Disable permission checking on the client side.
      - `x-systemd.automount`:  Enable automounting via systemd.
      - `noauto`:  Prevent mounting at boot.
      - `x-systemd.idle-timeout=60`: Unmount the share after 60 seconds of inactivity.
      - `gid=100`: Sets group ID to 100, usually the 'users' group.
      - `file_mode=0775`: Sets file permissions to 0775.
      - `dir_mode=0775`: Sets directory permissions to 0775.
      - `soft`: Defines soft mounts
      - `x-gvfs-hide` or `x-gvfs-show`:  Controls visibility in GVFS-based file managers.
      - `credentials=${config.sops.secrets."${cfg.secretName}".path}` or `guest`:  Authentication method.

## Usage Example

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./network-mounts.nix
  ];

  sops.secrets.onix_creds = {
    neededForUsers = true;
  };

  local.network-hosts.onix = "192.168.1.100";

  local.network-mounts = {
    enable = true;
    secretName = "onix_creds";
    serverIp = config.local.network-hosts.onix;
    mounts = [
      {
        shareName = "Media";
        localPath = "/media/Media";
      }
      {
        shareName = "Backups";
        localPath = "/media/Backups";
        noShow = true;
        options = [ "ro" ]; # Mount the backups share as read-only
      }
      {
        shareName = "Public";
        localPath = "/mnt/Public";
        noAuth = true;
      }
    ];
  };
}
```

In this example:

- The `network-mounts` module is enabled.
- A sops secret named `onix_creds` is declared (you'll need to create and populate this secret with the SMB credentials).
- The `serverIp` is set to 192.168.1.100 (read from the network hosts).
- Two shares, "Media" and "Backups", are configured to be mounted at `/media/Media` and `/media/Backups` respectively. The "Backups" share is hidden from the file manager and mounted read-only.
- The "Public" share is mounted as a guest without requiring authentication at `/mnt/Public`.

**Important Considerations:**

- **sops Configuration:** Ensure that sops is correctly configured and that the `onix_creds` secret exists and contains the username and password in the correct format (`username=xxx\npassword=xxx`).
- **Mount Point Directories:** Make sure that the `localPath` directories exist on your system before enabling the module. You can create them using `mkdir -p /media/Media /media/Backups`.
- **Permissions:** The default `file_mode` and `dir_mode` are set to `0775`, which gives read, write, and execute permissions to the owner and group, and read and execute permissions to others. Adjust these values as needed based on your security requirements.
- **`cifs-utils`:** This module automatically declares `pkgs.cifs-utils` as a system package. This is required for mounting SMB shares.
- **Systemd Automount:** The module uses systemd automount, which means that the shares will only be mounted when accessed. This can improve boot times and reduce resource usage.

By using this module, you can easily and securely manage your SMB/CIFS network mounts in a declarative and reproducible way. Remember to adjust the options to match your specific environment and security requirements.
