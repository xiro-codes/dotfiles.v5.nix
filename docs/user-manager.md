# user-manager

This Nix module provides automatic user group management for a NixOS system. It automatically discovers users defined in `currentHostUsers` and configures them with default settings and specified extra groups. This simplifies user management, especially when deploying NixOS to multiple hosts with similar user configurations. It also automatically enables `fish` shell support if any of the discovered users are configured to use it.

## Options

This module defines the following options under the `local.userManager` namespace:

### `local.userManager.enable`

Type: `Boolean`

Default: `false`

This option enables or disables the automatic user group management provided by this module. When enabled, the module configures discovered users with default settings and specified extra groups.

### `local.userManager.extraGroups`

Type: `List of String`

Default: `[ "wheel" "networkmanager" "input" "docker" ]`

Example: `[ "wheel" "networkmanager" "input" "video" "audio" "docker" ]`

This option specifies a list of groups to assign to all auto-discovered users on the host.  These groups are added to the `extraGroups` attribute of each user definition.  Common groups include `wheel` (for sudo access), `networkmanager` (for network configuration), `input` (for access to input devices), and `docker` (for Docker access). Customize this list based on the specific needs of your system.

## Configuration Details

This module performs the following configurations:

*   **Disables Sudo Password for Wheel Group:** Sets `security.sudo.wheelNeedsPassword` to `false`, allowing users in the `wheel` group to use `sudo` without a password.

*   **Configures Users:** Uses `lib.genAttrs` to iterate through the `currentHostUsers` and configure each user. For each user:
    *   Sets `isNormalUser` to `true`.
    *   Sets `extraGroups` to the value of `cfg.extraGroups`. This ensures that all discovered users have the specified groups assigned.

*   **Enables Fish Shell Support:**  If any of the discovered users are configured to use the `fish` shell (i.e., `config.users.users.${u}.shell == pkgs.fish`), the module enables the `programs.fish.enable` option.

## Usage Example

To enable automatic user group management and add users to the `video` and `audio` groups, add the following configuration to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./my-user-manager-module.nix  # Assuming this module is defined in a separate file
  ];

  local.userManager.enable = true;
  local.userManager.extraGroups = [ "wheel" "networkmanager" "input" "video" "audio" "docker" ];

  users.users.myuser = {
    isNormalUser = true;
    shell = pkgs.fish;
  };

  users.users.anotheruser = {
    isNormalUser = true;
  };
}
```

In this example:

*   The module is enabled.
*   All discovered users (e.g., `myuser` and `anotheruser` defined under `users.users`) will automatically be added to the `wheel`, `networkmanager`, `input`, `video`, `audio`, and `docker` groups.
*   `fish` shell support will be enabled automatically because `myuser` is configured to use `fish`.

## Notes

*   Make sure that the users defined in `currentHostUsers` are properly defined in `users.users`.
*   This module assumes that you want to treat all auto-discovered users as normal users (`isNormalUser = true`). If you have specific users that require different settings, you might need to adjust the module or override the settings for those users individually.
*   This module is designed for simplifying user management across multiple hosts. It might not be suitable for all use cases, especially if you need fine-grained control over individual user configurations.
