# bootloader

This module configures the bootloader for a NixOS system. It supports both UEFI and legacy BIOS boot modes, and offers different bootloader options for UEFI, including systemd-boot, GRUB, and Limine.  It also provides options for adding a recovery partition boot option and enabling Plymouth boot splash screen.

## Options

Here's a detailed breakdown of the available configuration options:

### `local.bootloader.mode`

*   **Type:** `enum` of `["uefi", "bios"]`
*   **Default:** `"uefi"`
*   **Description:** Specifies the boot mode to use.

    *   `uefi`:  Configures the system to boot using UEFI (Unified Extensible Firmware Interface). This is the modern standard and generally recommended for newer hardware.
    *   `bios`:  Configures the system to boot using legacy BIOS (Basic Input/Output System). This is necessary for older hardware that does not support UEFI.

### `local.bootloader.uefiType`

*   **Type:** `enum` of `["systemd-boot", "grub", "limine"]`
*   **Default:** `"systemd-boot"`
*   **Description:**  Selects the UEFI bootloader to use when `mode` is set to `"uefi"`.

    *   `systemd-boot`: Uses systemd-boot, a simple and lightweight UEFI bootloader integrated with systemd. It is generally easy to configure and works well with NixOS.
    *   `grub`: Uses GRUB (GRand Unified Bootloader), a powerful and versatile bootloader with a wide range of features.  It can be more complex to configure than systemd-boot but provides greater flexibility.
    *   `limine`: Uses Limine, a modern, advanced, and blazingly fast bootloader. It offers some unique features and is designed to be extensible.

### `local.bootloader.device`

*   **Type:** `string`
*   **Default:** `""`
*   **Example:** `"/dev/sda"`
*   **Description:**  Specifies the device where the BIOS bootloader should be installed. **This option is only relevant when `mode` is set to `"bios"`**.  It should point to the hard drive (e.g., `/dev/sda`) and not a specific partition.  Use `lsblk` or `fdisk -l` to identify the correct device.  **Important:** Installing to the wrong device can render your system unbootable.

### `local.bootloader.addRecoveryOption`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**  Determines whether to add a boot entry for a recovery partition to the bootloader menu. When set to `true`, a special boot option will appear, allowing you to boot into a recovery environment.  This is useful for troubleshooting and system maintenance.  Requires `local.bootloader.recoveryUUID` to also be set.

### `local.bootloader.recoveryUUID`

*   **Type:** `string`
*   **Default:** `""`
*   **Example:** `"12345678-1234-1234-1234-123456789abc"`
*   **Description:**  Specifies the UUID (Universally Unique Identifier) of the recovery partition. This UUID is used to identify the correct partition to boot from when the recovery option is selected.  You can obtain the UUID of your recovery partition using the `blkid` command.  This option is only relevant when `local.bootloader.addRecoveryOption` is set to `true`.

    *   To find the UUID of a partition, run `sudo blkid /dev/sdXN`, replacing `/dev/sdXN` with the device name of your partition (e.g. `/dev/sda2`).

### `local.bootloader.enablePlymouth`

*   **Type:** `boolean`
*   **Default:** `true`
*   **Description:**  Enables or disables the Plymouth boot splash screen. Plymouth provides a graphical boot experience, hiding the boot messages and displaying a visually appealing animation or image while the system is starting up.  Disabling Plymouth can reveal underlying boot processes which might be helpful for debugging.
