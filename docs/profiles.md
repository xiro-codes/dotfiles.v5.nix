# Profiles

This section documents the available profiles for both systems and home configurations.

## System Profiles

System profiles are used to configure the base system. They are located in the `systems/profiles` directory.

### Base

This profile contains the base configuration for a new system. It includes common settings for nix, security, users, and networking.

### Client

This profile configures a system to be a client of the server. It sets up backup services and network mounts that depend on the server being available.

### Server

This profile contains the configuration for a server system. It enables various services such as Pi-hole, Gitea, a reverse proxy, and media services.

### Workstation

This profile contains the configuration for a desktop system, including graphics drivers and other desktop-oriented configuration.

### Limine UEFI

This profile configures the Limine bootloader for UEFI systems.

## Home Profiles

Home profiles are used to configure the user environment. They are located in the `home/profiles` directory.

### Base

This profile contains the base configuration for a user. It includes common shell tools, editors, and git configuration.

### Desktop

This profile contains the configuration for a desktop user. It includes the configuration for Hyprland, Waybar, and other desktop applications.

### Server

This profile contains configuration for a user on a server system. It currently only includes a minimal set of desktop applications.

### Workstation

This profile contains the configuration for a workstation user. It is identical to the `desktop` profile.
