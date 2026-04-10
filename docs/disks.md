```markdown
# disks

This module provides basic configuration for disk management, enabling services that allow for automatic mounting of removable drives and seamless integration with the desktop environment.

## Options

### `local.disks.enable`

Type: boolean

Default: `false`

Description:

Enables basic configuration for disk management. When enabled, this module activates the following services:

-   `gvfs`: Provides a virtual filesystem layer that allows applications to access files on various storage devices (e.g., USB drives, network shares) in a uniform way. This improves integration with graphical environments and file managers.

-   `udisks2`: A system service that manages storage devices and provides a D-Bus API for applications to interact with them.  It handles tasks like mounting, unmounting, formatting, and ejecting disks. This service is crucial for automatic mounting of removable drives on desktop environments.

-   `devmon`: Monitors device events and automatically mounts/unmounts removable media such as USB drives when they are plugged in or removed.  This provides a convenient plug-and-play experience.

When disabled, none of the aforementioned services are enabled, leaving disk management to the base system configuration.  This is useful when you want to manage disks manually or rely on an alternative disk management solution.
```
