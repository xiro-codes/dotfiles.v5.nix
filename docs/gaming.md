```markdown
# Gaming

This Nix module provides a convenient way to enable various gaming-related optimizations and software packages on your NixOS system. It handles configuration for Steam, Bluetooth controllers, GameMode, and various controller types like Xbox and DualSense. Enabling this module will install and configure these tools to provide a better gaming experience.

## Options

This module exposes the following configurable options under the `local.gaming` scope:

### `local.gaming.enable`

Type: `Boolean`

Default: `false`

Description:
A master switch that enables or disables all gaming optimizations and software provided by this module. Setting this to `true` will activate the following configurations:

*   **Steam:** Enables Steam, opens firewall ports for remote play and dedicated servers.
*   **Bluetooth Controller Optimization:** Optimizes Bluetooth for controllers by adjusting kernel polling intervals, reducing latency.
*   **GameMode:** Installs and enables GameMode, allowing games to request temporary system optimizations.
*   **Controller Support:** Enables support for Xbox (via `xpadneo`), Nintendo Joy-Cons (via `joycond`), and various other controllers via udev rules and the steam-hardware package.

## Detailed Configuration

When `local.gaming.enable` is set to `true`, the following configurations are applied:

### Steam (`programs.steam`)

*   `enable = true;`
    *   Enables the Steam client.
*   `remotePlay.openFirewall = true;`
    *   Opens the necessary firewall ports for Steam Remote Play functionality, allowing you to stream games from your computer to other devices.
*   `dedicatedServer.openFirewall = true;`
    *   Opens the necessary firewall ports for hosting dedicated game servers on your machine.

### Bluetooth Controller Optimization (`boot.kernel.sysctl`)

*   `"net.core.netdev_max_backlog" = 5000;`
    *   Adjusts the `net.core.netdev_max_backlog` kernel parameter via `sysctl`.  This parameter controls the maximum number of packets allowed to queue on a network interface.  Increasing this value (to 5000 in this case) can help reduce latency and improve responsiveness with Bluetooth controllers, especially in scenarios with high network traffic. It changes how the kernel handles network device input buffering.

### GameMode (`programs.gamemode`)

*   `enable = true;`
    *   Enables the GameMode service. GameMode is a daemon that allows games to request temporary optimizations from the system, such as increased CPU priority or disabling power saving features. This can lead to smoother gameplay and improved performance.

### Controller Support

*   `hardware.xpadneo.enable = true;`
    *   Enables the `xpadneo` driver for Xbox One wireless controllers. This driver provides improved support for Xbox One controllers compared to the default drivers, including better force feedback and rumble support.

*   `services.joycond.enable = true;`
    *   Enables the `joycond` service, which provides support for Nintendo Joy-Cons. This allows you to use Joy-Cons as input devices with your system.

*   `hardware.steam-hardware.enable = true;`
    *   Enables the `steam-hardware` package, providing udev rules and other configuration files necessary for proper support of various Steam-related hardware devices, including the Steam Controller, Steam Deck, and related peripherals.

### Udev Rules (`services.udev.extraRules`)

This section defines custom udev rules to ensure proper permission handling for specific controllers, particularly the PlayStation 5 DualSense controller.  Udev rules are used by the system to automatically configure devices when they are connected.

*   ```nix
    ''
      # PS5 DualSense wired (USB)
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666"
      # PS5 DualSense Bluetooth
      KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0666"
    ''
    ```
    *   **`KERNEL=="hidraw*"`**: This rule applies to devices that appear as `hidraw` (Human Interface Device Raw) devices in the `/dev` directory.  `hidraw` is a generic interface for communicating with HID devices.
    *   **`ATTRS{idVendor}=="054c"`**: This attribute checks the device's vendor ID. `054c` is the vendor ID for Sony.
    *   **`ATTRS{idProduct}=="0ce6"`**: This attribute checks the device's product ID. `0ce6` is the product ID for the DualSense controller.
    *   **`KERNELS=="*054C:0CE6*"`**:  In the Bluetooth rule, this checks that the kernel identifies the device with both the vendor (054C) and product (0CE6) ID.  The `*` wildcards allow for variations in the surrounding identifier string.
    *   **`MODE="0666"`**: This sets the file permissions of the device node to `0666`, which grants read and write access to all users.  This is necessary for applications (like games) to be able to communicate with the DualSense controller without requiring elevated privileges (root).  This ensures the controller can be used without requiring `sudo` or other privilege escalation.
```
