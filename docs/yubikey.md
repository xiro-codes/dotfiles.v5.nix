# yubikey

This module provides comprehensive support for YubiKey integration within a NixOS system. It includes installation of necessary packages, udev rules, PC/SC daemon configuration, and GPG agent adjustments. Furthermore, it sets up a systemd service to detect when the YubiKey requires a touch, enhancing the user experience. This module aims to streamline YubiKey usage for authentication and security purposes, particularly with GPG and SSH.

## Options

This module defines the following options under the `local.yubikey` namespace:

### `local.yubikey.enable`

**Type:** `boolean`

**Default Value:** `false`

**Description:**
Enables or disables YubiKey support and GPG/SSH integration. When enabled, the module installs necessary packages, configures udev rules, enables the PC/SC daemon, adjusts the GPG agent settings, and sets up a systemd service to detect when the YubiKey is waiting for a touch.  Disabling this option will remove these configurations.

## Detailed Configuration

When `local.yubikey.enable` is set to `true`, the following configurations are applied:

### Package Installation

The following packages are installed as system packages:

*   `yubioath-flutter`:  A Flutter-based application for managing Yubico OTP applications.  Useful for generating and managing time-based one-time passwords (TOTP) and HMAC-based one-time passwords (HOTP) on your YubiKey.
*   `yubikey-manager`:  A command-line tool and GUI application for managing various YubiKey functionalities.  Allows configuration of OTP, FIDO, PIV, and OATH applications.
*   `yubikey-personalization`:  Tools for personalizing and configuring YubiKeys. Includes command-line tools for configuring OTP slots.
*   `yubico-piv-tool`: A tool for managing the PIV (Personal Identity Verification) application on YubiKeys.  Allows managing certificates and keys stored on the YubiKey for authentication and encryption.
*   `yubikey-touch-detector`: A utility that detects when the YubiKey requires a touch and displays a notification.  Improves usability by alerting users when their YubiKey needs interaction.

### Udev Rules

The following packages are added to `services.udev.packages`:

*   `yubikey-personalization`:  Ensures proper udev rules are installed for device recognition and interaction.
*   `libu2f-host`: Provides necessary library files to enable FIDO/U2F functionality on YubiKeys.

These packages provide the necessary udev rules to properly detect and interact with the YubiKey device, allowing it to be used for authentication and other security functions.

### PC/SC Daemon

The `services.pcscd.enable` option is set to `true`. This enables the PC/SC (Personal Computer/Smart Card) daemon, which is necessary for interacting with smart card devices, including YubiKeys when using PIV or other smart card applications.

### GPG Agent Configuration

The `programs.gnupg.agent` options are configured as follows:

*   `enable` is set to `false`. Disables the default GPG agent managed by the `programs.gnupg.agent` module to prevent conflicts with the YubiKey's smart card functionalities and to avoid managing keys through the usual GPG mechanisms.  It's important to manage GPG keys that exist on the YubiKey through YubiKey tools (like `yubico-piv-tool`) and not through the standard GPG mechanisms.
*   `enableSSHSupport` is set to `false`. Disables SSH support for the GPG agent to prevent conflicts with the YubiKey's SSH functionalities. SSH support via the YubiKey is more commonly managed through specific configurations for `ssh-agent` or using tools like `yubico-piv-tool` to manage SSH keys stored on the YubiKey.
*   `pinentryPackage` is set to `pkgs.pinentry-all`. Specifies the pinentry program to use for prompting the user for their PIN. Using `pinentry-all` provides a variety of graphical and terminal-based pinentry programs, ensuring compatibility with different desktop environments.  This is used when interacting with the GPG agent for operations requiring authentication with the YubiKey.
*   `settings` are configured with:
    *   `default-cache-ttl` set to `600` seconds (10 minutes). Defines the default time-to-live for cached PINs.  After this time, the user will be prompted for their PIN again.
    *   `max-cache-ttl` set to `7200` seconds (2 hours). Defines the maximum time-to-live for cached PINs.  The PIN will never be cached for longer than this time.

These settings configure the GPG agent to work effectively with the YubiKey, manage PIN caching, and avoid conflicts with other services.

### YubiKey Touch Detector Systemd Service

A systemd user service named `yubikey-touch-detector` is created with the following configuration:

*   `description` is set to "Detects when your YubiKey is waiting for a touch". Provides a human-readable description of the service.
*   `wantedBy` is set to `[ "graphical-session.target" ]`.  Specifies that the service should be started when a graphical session is available.  This ensures the touch detector is running when the user is logged into their graphical environment.
*   `serviceConfig` includes:
    *   `ExecStart` is set to `${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector`.  Specifies the command to execute when the service starts.  This runs the `yubikey-touch-detector` program.
    *   `Restart` is set to `on-failure`.  Specifies that the service should be restarted automatically if it fails.

This systemd service provides a convenient way to detect when the YubiKey requires a touch, improving the user experience and ensuring timely interaction with the device.
