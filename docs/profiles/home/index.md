# Home Profiles Index

Home profiles define the user environment and Home Manager configuration.

- **[Base](base.md)**: Core shell environment and tools.
- **[Desktop](desktop.md)**: Appearance and GUI application settings.
- **[Server](server.md)**: Optimized environment for server management.
- **[Workstation](workstation.md)**: Combined desktop and development tools.
<!-- slide -->
# Base Home Profile

The Base home profile provides the core shell and CLI environment.

## Configuration Details

- **Location**: `home/profiles/base/`
- **Modules**:
    - **`nix.nix`**: User-specific Nix settings.
    - **`shell.nix`**: Fish shell, Starship prompt, and aliases.
    - **`tools.nix`**: Common CLI utilities (Yazi, Git, etc.).
<!-- slide -->
# Desktop Home Profile

The Desktop home profile configures the graphical user environment.

## Configuration Details

- **Location**: `home/profiles/desktop/`
- **Modules**:
    - **`appearance.nix`**: Theming, fonts, and cursors.
    - **`apps.nix`**: GUI applications (Kitty, Firefox, etc.).
    - **`window-manager.nix`**: Hyprland configuration, Waybar, and Mako.
<!-- slide -->
# Server Home Profile

The Server home profile is optimized for managing server systems.

## Configuration Details

- **Location**: `home/profiles/server/`
- **Features**: Includes the base profile and additional tools useful for server administration and monitoring.
<!-- slide -->
# Workstation Home Profile

The Workstation home profile is a comprehensive setup for development and productivity.

## Configuration Details

- **Location**: `home/profiles/workstation/`
- **Features**: Combines the **Base** and **Desktop** profiles with additional workstation-specific tools and configurations.
