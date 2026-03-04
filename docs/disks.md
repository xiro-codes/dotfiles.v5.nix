# disks

This Nix module provides a convenient way to enable basic disk management services on your system. It configures `gvfs`, `udisks2`, and `devmon` to allow for easy mounting and management of removable media and other disks.  This is useful for desktop environments where you want automatic mounting and unmounting of USB drives, external hard drives, and other storage devices.

## Options

This module exposes a single option to control its behavior:

### `local.disks.enable`

**Type:** boolean

**Default:** `false`

**Description:**

Enables the basic configuration for disk management. When set to `true`, this option activates the following services:

*   `gvfs`:  The GNOME Virtual File System, which provides a userspace virtual filesystem on top of FUSE.  It's widely used by GNOME and other desktop environments for transparently accessing remote filesystems (like SFTP, WebDAV, etc.) and removable media.  Enabling `gvfs` generally makes accessing these resources much easier through your file manager (e.g., Nautilus). Crucially, it also provides the backends to mount disks managed by `udisks2`.

*   `udisks2`:  A system service that manages disk devices. It provides an API for applications to query and manipulate disks, partitions, and filesystems.  `udisks2` is responsible for tasks such as mounting and unmounting removable media, formatting disks, and partitioning drives. It runs as a system service, providing a central point of control for disk management.

*   `devmon`:  A daemon that automatically mounts and unmounts removable devices when they are inserted or removed.  This provides a user-friendly experience by eliminating the need to manually mount and unmount devices through the command line or a file manager. It utilizes `udisks2` internally and provides a more automatic experience, particularly for desktop environments.

**Example Usage:**

To enable the disk management module, add the following to your `configuration.nix`:

```nix
{
  imports = [
    ./modules/disks.nix  # Assuming this module is located in ./modules/disks.nix
  ];

  local.disks.enable = true;
}
```

This configuration will enable `gvfs`, `udisks2`, and `devmon`, providing automatic disk mounting and management capabilities.
