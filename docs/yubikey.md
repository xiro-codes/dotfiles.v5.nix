# yubikey

This Nix module provides comprehensive support for YubiKey devices, streamlining GPG and SSH integration and installing necessary tools for managing and utilizing your YubiKey. It automatically installs essential packages, configures udev rules, enables PC/SC smart card daemon, and sets up a systemd service to detect when your YubiKey requires a touch.

## Options

This module exposes the following options within the `local.yubikey` namespace:

### `local.yubikey.enable`

**Type:** Boolean

**Default Value:** `false`

**Description:**
Enables YubiKey support and GPG/SSH integration. This option controls whether the module activates its configuration, installing necessary packages, setting up udev rules, enabling `pcscd`, configuring `gnupg`, and establishing the `yubikey-touch-detector` service.  When set to `true`, it indicates that you intend to use a YubiKey for authentication, encryption, and other security-related operations, and initiates the configuration process.

## Details

When `local.yubikey.enable` is set to `true`, the following actions are performed:

*   **Packages Installation:**
    The following packages are installed to provide the necessary tools for YubiKey management and use:
    *   `yubioath-flutter`: A Flutter-based application for managing Yubico's OATH functionality, often used for two-factor authentication (2FA).
    *   `yubikey-manager`: The official YubiKey Manager application, providing a graphical interface for configuring various YubiKey settings and features.
    *   `yubikey-personalization`: Command-line tools for personalizing and configuring the YubiKey.  This is a low-level utility for advanced configurations.
    *   `yubico-piv-tool`: A command-line tool for interacting with the YubiKey's PIV (Personal Identity Verification) application, used for certificate management and related operations.
    *   `yubikey-touch-detector`: A utility for detecting when the YubiKey requires a touch to complete an operation.

*   **udev Rules Configuration:**
    udev rules are configured to allow proper access to the YubiKey device.  This involves installing the following packages:
    *   `yubikey-personalization`:  Again, included for its udev rules to properly identify the YubiKey.
    *   `libu2f-host`:  Provides necessary components for U2F (Universal 2nd Factor) support, enabling the YubiKey for web-based two-factor authentication.

*   **PC/SC Smart Card Daemon (pcscd) Enablement:**
    The `pcscd` service is enabled, which provides a standard interface for applications to communicate with smart card readers, including the YubiKey. `services.pcscd.enable = true` configures the system to automatically start and manage the pcscd service, making the YubiKey accessible to applications that use the PC/SC standard.

*   **GnuPG Agent Configuration:**
    The GnuPG agent is configured to work seamlessly with the YubiKey.
    *   `enable = false`: Disables the default GnuPG agent managed by NixOS.  This is likely to prevent conflicts if you're manually configuring the agent to specifically use the YubiKey.
    *   `enableSSHSupport = false`: Disables SSH support in the default GnuPG agent.  This can prevent conflicts and is often necessary when you want the YubiKey to handle SSH authentication more directly.
    *   `pinentryPackage = pkgs.pinentry-all`: Sets the `pinentry` program used for entering PINs. `pinentry-all` is a meta-package that includes several different `pinentry` implementations, allowing the user to choose the most suitable one (e.g., GTK, Qt, curses).
    *   `settings`:
        *   `default-cache-ttl = 600`: Sets the default Time-To-Live (TTL) for cached PINs to 600 seconds (10 minutes).
        *   `max-cache-ttl = 7200`: Sets the maximum TTL for cached PINs to 7200 seconds (2 hours).  This controls how long the PIN can be cached, affecting security and convenience.

*   **YubiKey Touch Detector Service:**
    A `systemd` user service, `yubikey-touch-detector`, is created to detect when the YubiKey is waiting for a touch.  This can be used to provide visual or auditory feedback to the user.
    *   `description`: A human-readable description of the service.
    *   `wantedBy = [ "graphical-session.target" ]`: Specifies that this service should be started when the graphical session is active. This ensures it only runs when a user is logged in graphically.
    *   `serviceConfig`: Configures the service's behavior.
        *   `ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector"`: Specifies the command to execute when the service starts.  This runs the `yubikey-touch-detector` executable.
        *   `Restart = "on-failure"`: Configures the service to automatically restart if it fails. This ensures that the touch detection functionality remains available even if the detector encounters an error.
