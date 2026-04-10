```markdown
# bootloader

This Nix module configures the system's bootloader, supporting both UEFI and legacy BIOS modes. It provides options for selecting the boot mode, choosing a specific UEFI bootloader (systemd-boot, GRUB, or Limine), configuring the device for BIOS boot, adding a recovery partition boot option, and enabling Plymouth for a boot splash screen.

## Options

### `local.bootloader.mode`

*   **Type:** `enum [ "uefi" "bios" ]`
*   **Default:** `"uefi"`
*   **Description:** Specifies the boot mode to use.  Select either `"uefi"` for UEFI-based systems or `"bios"` for legacy BIOS systems.  The choice of boot mode affects which bootloader configurations are applied.  Carefully select the correct mode based on your system's firmware.

### `local.bootloader.uefiType`

*   **Type:** `enum [ "systemd-boot" "grub" "limine" ]`
*   **Default:** `"systemd-boot"`
*   **Description:**  Determines which UEFI bootloader to use when `mode` is set to `"uefi"`.

    *   `"systemd-boot"`: Configures `systemd-boot` as the UEFI bootloader. It's simple and integrates well with systemd.  Good for most modern UEFI systems.
    *   `"grub"`: Configures GRUB (GRand Unified Bootloader) as the UEFI bootloader.  GRUB is highly configurable and supports advanced features like chainloading and custom boot menus. Choose if you need advanced boot capabilities.
    *   `"limine"`: Configures Limine as the UEFI bootloader.  Limine is a modern, lightweight bootloader. It supports various boot protocols.  Good for niche uses.

### `local.bootloader.device`

*   **Type:** `str`
*   **Default:** `""`
*   **Example:** `"/dev/sda"`
*   **Description:**  Specifies the device where the BIOS bootloader should be installed.  This option is **required** when `mode` is set to `"bios"`.  It represents the hard drive or partition that the BIOS will use to load the bootloader from.
    * Use `lsblk` or a similar utility to determine the correct device identifier. **Incorrect configuration may result in an unbootable system.**

### `local.bootloader.addRecoveryOption`

*   **Type:** `bool`
*   **Default:** `false`
*   **Description:**  Determines whether to add a recovery partition boot option to the bootloader menu.  When enabled (`true`), a boot entry will be created that allows booting from a recovery partition.  This can be useful for system recovery and maintenance. Requires `recoveryUUID` to be configured.

### `local.bootloader.recoveryUUID`

*   **Type:** `str`
*   **Default:** `""`
*   **Example:** `"12345678-1234-1234-1234-123456789abc"`
*   **Description:** Specifies the UUID (Universally Unique Identifier) of the recovery partition. This UUID is used to identify the partition in the bootloader configuration. It is essential if `addRecoveryOption` is set to `true` to successfully boot from the recovery partition.
    * You can find the UUID of the recovery partition using the `blkid` command.

### `local.bootloader.enablePlymouth`

*   **Type:** `bool`
*   **Default:** `true`
*   **Description:**  Enables or disables the Plymouth boot splash screen.  When enabled (`true`), Plymouth will display a graphical splash screen during the boot process. Disabling it (`false`) shows the text-based boot output. Enabling it also set kernel parameters "quiet" and "splash", console log level to 0 and disables verbose initrd output.
```
