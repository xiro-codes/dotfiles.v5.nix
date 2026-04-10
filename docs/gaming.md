```markdown
# gaming

This Nix module provides a convenient way to enable various gaming-related optimizations and features on your NixOS system. It configures Steam, optimizes Bluetooth for lower controller latency, enables GameMode, and provides support for Xbox, DualSense, and other controllers. This helps create a smoother and more enjoyable gaming experience.

## Options

This module defines the following options under the `local.gaming` namespace:

### `local.gaming.enable`

**Type:** `boolean`

**Default Value:** `false`

**Description:**

Enables or disables all gaming optimizations and features provided by this module. When enabled, the following configurations are applied:

*   Steam is enabled with firewall rules for Remote Play and dedicated servers.
*   Kernel parameters are adjusted to optimize Bluetooth latency for controllers.
*   GameMode is enabled to allow games to request temporary system optimizations.
*   Drivers and services for Xbox and DualSense controllers are enabled.
*   Udev rules for various controllers, including DualSense and Steam Controller, are installed.

## Configuration Details

When `local.gaming.enable` is set to `true`, the following changes are applied to the system configuration:

*   **Steam:**
    *   `programs.steam.enable = true;` enables Steam.
    *   `programs.steam.remotePlay.openFirewall = true;` opens the firewall for Steam Remote Play.
    *   `programs.steam.dedicatedServer.openFirewall = true;` opens the firewall for Steam dedicated servers.
*   **Bluetooth Optimization:**
    *   `boot.kernel.sysctl."net.core.netdev_max_backlog" = 5000;` increases the network device backlog to reduce latency for Bluetooth controllers. This is achieved by setting a custom `sysctl` value.
*   **GameMode:**
    *   `programs.gamemode.enable = true;` enables the GameMode service, allowing games to request performance boosts.
*   **Controller Support:**
    *   `hardware.xpadneo.enable = true;` enables the `xpadneo` driver for Xbox One wireless controllers.
    *   `services.joycond.enable = true;` enables the `joycond` service for Nintendo Joy-Cons.
    *   `hardware.steam-hardware.enable = true;` enables udev rules for Steam Controller and other Steam hardware.
*   **Udev Rules:**
    *   `services.udev.extraRules` includes custom udev rules to grant access to DualSense controllers (wired and Bluetooth) without requiring root privileges.

## Example Usage

To enable gaming optimizations, add the following to your `configuration.nix`:

```nix
{
  imports = [
    ./modules/gaming.nix # Assuming the module is located at ./modules/gaming.nix
  ];

  local.gaming.enable = true;
}
```

After adding this configuration, rebuild your system with `sudo nixos-rebuild switch` to apply the changes.
```
