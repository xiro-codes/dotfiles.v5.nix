# System Profiles Index

System profiles define the role and configuration of a NixOS host.

- **[Base](base.md)**: Common settings for all systems.
- **[Client](client.md)**: Configuration for client systems connecting to the NAS.
- **[Server](server.md)**: Media, networking, and sharing services.
- **[AI Server](ai-server.md)**: Dedicated AI and machine learning services.
- **[Workstation](workstation.md)**: Complete desktop environment and software.
- **[Limine UEFI](limine-uefi.md)**: Limine bootloader configuration.
<!-- slide -->
# Base System Profile

The Base profile contains the foundational configuration for all systems.

## Configuration Details

- **Location**: `systems/profiles/base.nix`
- **Modules Enabled**:
    - `local.security`: Basic system hardening.
    - `local.dotfiles-sync`: Automated dotfiles management.
    - `local.userManager`: Handles user creation and group assignment.
    - `local.nix-core-settings`: Optimizations for Nix.
    - `local.localization`: Timezone and locale.
    - `local.disks`: GVFS and UDisks support.
    - `local.secrets`: SOPS-based secrets management.
    - `local.network`: Base networking using NetworkManager.
<!-- slide -->
# Client Profile

The Client profile is intended for systems that rely on the central NAS (Onix) for storage and backups.

## Configuration Details

- **Location**: `systems/profiles/client.nix`
- **Features**:
    - **Backups**: Automatically configures `backup-manager` to store backups on the NAS.
    - **Network Mounts**: Configures NFS/SMB mounts for common shares (Media, Storage, Music, etc.).
    - **Maintenance**: Enables automatic system upgrades.
    - **Recovery**: Enables the recovery builder for bootloader safety.
<!-- slide -->
# Server Profile

The Server profile provides the core infrastructure for the home network.

## Configuration Details

- **Location**: `systems/profiles/server/`
- **Modules**:
    - **`media.nix`**: Plex, Jellyfin, Komga, and Audiobookshelf.
    - **`networking.nix`**: Reverse proxy (Nginx) and Pi-hole.
    - **`services.nix`**: Gitea, Dashboard, and Harmonia cache.
    - **`sharing.nix`**: Samba sharing for the local network.
<!-- slide -->
# AI Server Profile

The AI Server profile provides dedicated resources for local AI and machine learning.

## Configuration Details

- **Location**: `systems/profiles/ai-server/`
- **Modules**:
    - **`ai.nix`**: Ollama and Open WebUI.
    - **`networking.nix`**: Reverse proxy routing for AI services.
    - **`services.nix`**: Support for KMS console (`kmscon`).
<!-- slide -->
# Workstation Profile

The Workstation profile provides a complete desktop experience.

## Configuration Details

- **Location**: `systems/profiles/workstation/`
- **Modules**:
    - **`desktop.nix`**: Hyprland, Stylix theming, and Gaming optimizations.
    - **`hardware.nix`**: Pipewire audio and Bluetooth support.
    - **`software.nix`**: Installation of common GUI applications.
<!-- slide -->
# Limine UEFI Profile

Configures the Limine bootloader for UEFI-based systems.

## Configuration Details

- **Location**: `systems/profiles/limine-uefi.nix`
- **Features**: Sets up Limine as the primary bootloader with UEFI support.
