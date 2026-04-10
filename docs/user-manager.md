# user-manager

This Nix module provides a convenient way to automatically manage user groups for all auto-discovered users on a host.  It ensures that users are configured as normal users and are added to a set of predefined or user-specified groups.  It also disables the default sudo password requirement for the `wheel` group and enables the `fish` shell. This module simplifies the process of setting up user environments across multiple machines.

## Options

This module defines the following options within the `local.userManager` namespace:

### `local.userManager.enable`

Type: `boolean`

Default: `false`

Description: Enables or disables automatic user group management via this module. When enabled, the module will automatically configure auto-discovered users with the specified groups and settings.  This serves as a master switch for the entire module's functionality.

### `local.userManager.extraGroups`

Type: `list of strings`

Default: `[ "wheel" "networkmanager" "input" "docker" "cdrom" "incus-admin" ]`

Example: `[ "wheel" "networkmanager" "input" "video" "audio" "docker" ]`

Description:  A list of group names to assign to all auto-discovered users on the host.  These groups will be added to each user's `extraGroups` attribute.  This allows for easily granting access to system resources such as devices, network services, and administration tools.

   - `"wheel"`: Grants administrative privileges via `sudo`. **Note:** This module automatically sets `security.sudo.wheelNeedsPassword = false`.
   - `"networkmanager"`: Allows users to manage network connections.
   - `"input"`: Grants access to input devices such as keyboards and mice.
   - `"docker"`:  Allows users to interact with the Docker daemon (if installed).
   - `"cdrom"`: Grants access to CD-ROM drives.
   - `"incus-admin"`: Allows users to administer Incus containers.

You can customize this list to suit your specific needs, adding or removing groups as required.  Ensure that the specified groups actually exist on the system or are defined elsewhere in your Nix configuration. If non-existent groups are specified, the user creation might fail.
