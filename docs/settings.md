# settings

This module configures basic system and Nix settings. It enables flakes, experimental features, allows unfree packages, installs essential system packages, and ignores ISO 9660 recovery partitions from automount. This module provides a convenient way to set up a development environment or personal system with sane defaults and commonly used tools.

## Options

### `local.settings.enable`

Type: boolean

Default: `false`

Description:
Enables or disables the basic system and Nix settings provided by this module.  When enabled, the module configures Nix settings, allows unfree packages, installs essential system packages, and configures udev rules.

## Configuration Details

When `local.settings.enable` is set to `true`, the following configurations are applied:

*   **Nix Configuration:**
    *   `nix.settings.accept-flake-config` is set to `true`, allowing flake configurations to be accepted.
    *   `nix.settings.experimental-features` is set to `[ "nix-command" "flakes" ]`, enabling experimental Nix features like the `nix` command and flakes.
    *   `nix.extraOptions` is set to `'builders-use-substitutes = true'`, forcing builders to use substitutes if available for faster build times.

*   **Unfree Packages:**
    *   `nixpkgs.config.allowUnfree` is set to `true`, allowing the installation of packages that are considered unfree.

*   **System Packages:**
    *   `environment.systemPackages` includes `neovim`, providing a basic, and highly extendable, text editor for development.

*   **Automount Configuration:**
    *   `services.udev.extraRules` is configured to ignore ISO 9660 recovery partitions from automount. This prevents the system from automatically mounting recovery partitions with the UUID `1980-01-01-00-00-00-00`, which can be useful to avoid unnecessary mounts and potential conflicts.

## Usage Example

To enable these settings, add the following to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the module where this configuration is defined
    ];

  local.settings.enable = true;

  # Other system configurations...
}
```

This configuration will enable the Nix settings, allow unfree packages, install Neovim, and ignore ISO 9660 recovery partitions from automount.
