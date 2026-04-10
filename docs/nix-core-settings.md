```markdown
# nix-core-settings

This Nix module provides a set of basic system and Nix configurations. It enables flakes, allows unfree packages, installs essential system packages, configures Nix settings, and adds a udev rule to ignore ISO 9660 recovery partitions from automount. This module serves as a foundational layer for customizing a NixOS system with common and convenient settings.

## Options

This module defines the following options:

### `local.nix-core-settings.enable`

Type: boolean

Default: `false`

Description:
Enables or disables the core Nix settings module. When enabled, it configures Nix to use flakes, allows unfree packages, installs system packages like neovim, and adds a udev rule to ignore ISO 9660 recovery partitions.

## Configuration Details

When `local.nix-core-settings.enable` is set to `true`, the module applies the following configurations:

*   **Nix Settings:**
    *   `nix.settings.accept-flake-config = true;`: Enables acceptance of flake configurations, allowing Nix to use flake.nix files to define environments.
    *   `nix.settings.experimental-features = [ "nix-command" "flakes" ];`: Enables experimental features like `nix-command` and `flakes`. This is crucial for using modern Nix features.

*   **Nix Extra Options:**
    *   `nix.extraOptions = '' builders-use-substitutes = true '';`: This option ensures that Nix attempts to use binary substitutes for builders if available, which can significantly speed up build times.

*   **Nixpkgs Configuration:**
    *   `nixpkgs.config.allowUnfree = true;`: Allows the installation of packages marked as unfree, providing access to a broader range of software.  Without this, certain proprietary or restricted software may not be installable.

*   **System Packages:**
    *   `environment.systemPackages = with pkgs; [ neovim ];`: Installs neovim (a powerful text editor) as a system-wide package, making it available in all environments.  You can extend this list to include other commonly used tools.

*   **udev Rules:**
    *   `services.udev.extraRules = '' ENV{ID_FS_UUID}=="1980-01-01-00-00-00-00", ENV{UDISKS_IGNORE}="1" '';`: Adds a udev rule that ignores ISO 9660 recovery partitions (often found on USB drives) from being automatically mounted. This prevents the system from attempting to mount partitions that are not intended to be user-accessible. The UUID `1980-01-01-00-00-00-00` is a common identifier for these types of partitions.

## Usage Example

To enable the core Nix settings, add the following to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    # other modules
  ];

  local.nix-core-settings.enable = true;

  # Any other configurations
}
```

This will enable flakes, allow unfree software, install neovim, and apply the udev rule.  You can then further customize the settings by modifying the `nix.settings`, `environment.systemPackages` and other configuration options to fit your specific needs.
```
