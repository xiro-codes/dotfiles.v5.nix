## NixOS YubiKey Module

This NixOS module simplifies YubiKey integration for GPG and SSH authentication. It installs necessary packages, configures udev rules, and sets up a YubiKey touch detector service.

**Purpose:**

*   Provides a convenient way to manage and use a YubiKey for secure authentication.
*   Installs required software for YubiKey functionality.
*   Configures system settings for seamless YubiKey integration.
* Adds a package that notifies you when your yubikey needs to be touched.

**Key Options:**

*   `local.yubikey.enable`: (Boolean)  Enables or disables the YubiKey module.  When enabled, the module installs packages, configures udev rules, enables the pcscd service, configure GPG agent, and configures the yubikey touch detector. This is the primary option to control the entire module's functionality.

