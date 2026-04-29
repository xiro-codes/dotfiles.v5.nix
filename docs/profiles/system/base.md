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
