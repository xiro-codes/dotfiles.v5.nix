# Profiles

This section documents the available profiles for both systems and home configurations.

## System Profiles

System profiles are used to configure the base system. They are located in the `systems/profiles` directory.

### Base

This profile contains the base configuration for a new system. It includes common settings for nix, security, users, and networking.

### Client

This profile configures a system to be a client of the server. It sets up backup services and network mounts that depend on the server being available.

### Server

This profile is now a collection of modules that provide services for a server. It is located in `systems/profiles/server`. The modules are:
- `default.nix`: Imports all other server modules.
- `media.nix`: Configures media services like Jellyfin and Plex.
- `networking.nix`: Configures networking services like Pi-hole and the reverse proxy.
- `services.nix`: Configures other services like Gitea and a file browser.
- `sharing.nix`: Configures file sharing services like Samba.

### Workstation

This profile is now a collection of modules that provide a complete desktop workstation setup. It is located in `systems/profiles/workstation`. The modules are:
- `default.nix`: Imports all other workstation modules.
- `desktop.nix`: Configures the desktop environment, including Hyprland and gaming settings.
- `hardware.nix`: Configures hardware support for audio and bluetooth.
- `software.nix`: Installs common desktop software.

### Limine UEFI

This profile configures the Limine bootloader for UEFI systems.

## Home Profiles

Home profiles are used to configure the user environment. They are located in the `home/profiles` directory.

### Base

This profile contains the base configuration for a user. It is located in `home/profiles/base` and includes the following modules:
- `default.nix`: Imports all other base modules.
- `nix.nix`: Configures nix settings.
- `shell.nix`: Configures the shell and related tools.
- `tools.nix`: Installs common CLI tools.

### Desktop

This profile contains the configuration for a desktop user. It is located in `home/profiles/desktop` and includes the following modules:
- `default.nix`: Imports all other desktop modules.
- `appearance.nix`: Configures the appearance of the desktop.
- `apps.nix`: Installs desktop applications.
- `window-manager.nix`: Configures the window manager.

### Server

This profile contains configuration for a user on a server system. It is located in `home/profiles/server` and includes the following modules:
- `default.nix`: Imports the base profile and server-specific tools.
- `tools.nix`: Installs server-specific CLI tools.

### Workstation

This profile contains the configuration for a workstation user. It imports the `desktop` and `base` profiles, and is located in `home/profiles/workstation`.
