```markdown
# nix-core-settings

This Nix module provides a convenient way to configure basic system and Nix settings. It enables features like flakes, allows unfree packages, installs essential system packages such as neovim, and configures udev rules to ignore ISO 9660 recovery partitions during automount. This module serves as a starting point for customizing a NixOS system.

## Options

This module defines the following options:

### `local.nix-core-settings.enable`

Type: boolean

Default: `false`

Description: Enables the basic system and Nix settings defined in this module.  When set to `true`, the module will configure Nix settings, allow unfree packages, install system packages, and set up udev rules. When `false`, no configuration is applied. Enabling this option is the primary way to activate the settings defined in this module. It's a crucial on/off switch for all the other configurations contained within the module.

## Configuration Details

When `local.nix-core-settings.enable` is set to `true`, the following configurations are applied:

### Nix Settings

*   **`nix.settings.accept-flake-config`**: This option is set to `true`. This setting allows flakes to define Nix settings, which can be helpful for managing project-specific configurations. It enhances the flake experience, letting flakes fully configure the Nix environment needed.

*   **`nix.settings.experimental-features`**: This option is set to `[ "nix-command" "flakes" ]`. This enables the `nix` command and flake support, which are essential for modern Nix development.  `nix-command` provides a more user-friendly command-line interface, and `flakes` enable reproducible builds and dependency management. Enabling these experimental features unlocks the power of modern Nix package management.

*   **`nix.extraOptions`**: This option adds the string `builders-use-substitutes = true` to the Nix daemon's configuration. This encourages the Nix daemon to use pre-built binaries from binary caches whenever available instead of building from source, dramatically speeding up build times.  This configuration directly improves build performance by leveraging existing cached builds.

### Nixpkgs Configuration

*   **`nixpkgs.config.allowUnfree`**: This option is set to `true`. This setting allows the installation of packages that are considered "unfree" according to the Nixpkgs definition.  This can be important for installing proprietary software or software with restrictive licenses.  Setting this to true provides access to a wider range of software that might otherwise be unavailable.

### System Packages

*   **`environment.systemPackages`**: This option adds `neovim` to the list of system packages. This ensures that Neovim, a modern text editor, is available in the system environment. This is a direct provision of a essential tool that will be on the system PATH available for use.

### Udev Rules

*   **`services.udev.extraRules`**: Adds a udev rule that prevents ISO 9660 recovery partitions from being automatically mounted by UDisks. Specifically, it targets partitions with the UUID `1980-01-01-00-00-00-00` and sets the `UDISKS_IGNORE` environment variable to `"1"` for those partitions.  This avoids automatically mounting partitions that are typically not intended for user access. This prevents common system annoyances that arise from these unwanted mountings.
```
