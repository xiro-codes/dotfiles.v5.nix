# gaming

This module provides gaming-related optimizations and configuration options for NixOS. It enables Steam, optimizes Bluetooth for controllers, enables Gamemode, and provides support for various game controllers (Xbox, DualSense, Joy-Cons).  It also allows you to easily install GOG games managed by `gog-nix`.

## Options

### `local.gaming.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**  Enables the gaming optimizations and configurations defined in this module.  This is the main switch to activate all features provided by this module.  If disabled, none of the other settings will have any effect.

### `local.gaming.games.<name>.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the installation of the GOG game named `<name>`. This option is dynamically generated for each game available in the `gog-nix` input.  `<name>` corresponds to the name of the GOG game package in `inputs.gog-nix.packages.x86_64-linux`. Example: `local.gaming.games.cyberpunk2077.enable = true;` would install Cyberpunk 2077 (assuming it exists in `gog-nix`).  This feature depends on the `gog-nix` flake and makes managing GOG games very straightforward.

## Details and Rationale

This module is designed to streamline the process of setting up a NixOS system for gaming.  It addresses several common configuration points:

*   **Steam Integration:** Enables Steam with appropriate firewall rules for Remote Play and dedicated servers. Steam is a widely used platform, and this module helps make it work seamlessly on NixOS.

*   **Bluetooth Optimization:** Reduces latency for Bluetooth controllers by adjusting kernel polling intervals.  This can significantly improve the responsiveness of controllers during gameplay, especially with Bluetooth-connected devices.

*   **Gamemode Support:** Enables Gamemode, which allows games to request temporary system optimizations for better performance. Gamemode is a valuable tool that can help improve frame rates and reduce input lag in games.

*   **Controller Support:**  Provides support for Xbox, DualSense, and Nintendo Joy-Con controllers through appropriate kernel modules and services.  It also enables udev rules for various controllers including DualSense and Steam Controller so that they can be used by non-root users, making them plug-and-play.

*   **GOG Game Integration:**  Facilitates the easy installation of GOG games managed via the `gog-nix` flake. It leverages the power of Nix to manage game dependencies and ensures consistent installation and execution. This functionality dynamically creates options for each GOG game present in the flake, providing a convenient and declarative way to manage your GOG library.
