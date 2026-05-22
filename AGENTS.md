# Agent Guidelines for NixOS Dotfiles

Welcome to the NixOS Dotfiles (v5) repository. This document provides critical information for AI agents working in this codebase.

## 🏗️ Architecture & Discovery Engine

This repository uses an **external automated discovery engine** via the `inputs-nix` flake. You **do not need to manually register new files or modules in `flake.nix`**. 

When you create a new module, package, or system, place it in the correct directory, and it will be automatically discovered and integrated into the flake outputs.

### Repository Structure
- `systems/<hostname>/`: Host-specific configurations (e.g., Onix, Ruby, Sapphire). Any directory here with a `configuration.nix` and `hardware-configuration.nix` becomes a `nixosConfiguration`.
- `systems/containers/<container-name>/`: Container configurations (e.g., Amber, Jade). These are auto-discovered by the `modules/system/containers` module using `builtins.readDir` and integrated via `self.nixosContainers`.
- `modules/system/<module-name>/`: Reusable NixOS modules. Must contain a `default.nix` and `meta.nix`.
- `modules/home/<module-name>/`: Reusable Home Manager modules. Also supports `meta.nix`.
- `home/<user>@<hostname>/`: Standalone Home Manager user configurations.
- `packages/<package-name>/`: Custom Nix packages.
- `shells/<shell-name>/`: Development shells (accessible via `nix develop .#<name>`).
- `templates/<template-name>/`: Project templates (ignore for system/home config tasks).
- `secrets/`: SOPS-encrypted secrets (`secrets.yaml`).

*Note: The `systems/profiles/` and `home/profiles/` folders are used as imports for reusable configurations, they are not auto-discovered as standalone systems/users.*

## 🛠️ Essential Commands

Always use `just` commands when available to ensure consistent application of flags (like `--impure`).

- `just switch`: Apply local configuration changes immediately (using `nh`).
- `just deploy <host>`: Deploy to a remote node using `deploy-rs`.
- `just run-test`: Build and launch the current configuration in a QEMU VM. **Always use this to test complex changes safely.**
- `just edit-secrets`: Edit the SOPS-encrypted secrets file.
- `just update-keys`: Update system keys for SOPS.

## 📝 Conventions & Patterns

### 1. Technical Patterns
- **Inherit Pattern**: NEVER use `lib.<function>` directly. ALWAYS use `inherit (lib) ...` at the top of the file/block.
- **Option Namespace**: All custom options must reside under the `local` namespace (e.g., `options.local.minecraft-server`). This applies to both system and home modules.
- **Internal Package Referencing**: Reference internal packages using `self.packages.${pkgs.stdenv.hostPlatform.system}.<package-name>`.
- **Discovery Pattern**: Use `builtins.readDir` to automate module/container loading. See `modules/system/containers/default.nix` for a reference implementation.

### 2. Specific Systems
- **Secrets Management**:
    - Use `local.secrets.keys` to map SOPS secrets to `$HOME/.secrets/<key>`.
    - User secrets are managed via `user-sops` and mapped automatically to the user's home.
- **Theming & Wallpapers**:
    - Centralized asset management via the `wallpapers` package.
    - Modules should use `local.wallpapers.path` for asset locations.
    - Stylix is used for system-wide theming, integrated with `local.wallpapers`.
- **Networking & Reverse Proxy**:
    - Use `lib/url-helpers.nix` for generating URLs that adapt to the reverse proxy state (HTTP vs HTTPS).
    - All hosts must have dummy interfaces defined in `topology.nix` for network mapping.
    - SSH host aliases are automatically mapped from `local.network-hosts` in `user-environment`.
- **Service Hardening**: Standard `systemd` hardening should be applied to all services. Common options include `CapabilityBoundingSet`, `PrivateDevices`, `ProtectHome`, and `RestrictAddressFamilies`.

### 3. Negative Patterns (What NOT to do)
- **DO NOT** use `lib.<function>` (e.g., `lib.mkIf`) directly anywhere in the code. ALWAYS use `inherit (lib) mkIf;`.
- **DO NOT** manually register new systems, modules, or packages in `flake.nix`.
- **DO NOT** import a module directly in host configurations. ONLY import profiles. Profiles will import the modules they need.
- **DO NOT** hardcode paths to wallpapers, icons, or remote URLs. Use the centralized management modules.
- **DO NOT** hardcode secrets, API keys, or passwords in Nix files. Always use `sops-nix` or the `local.secrets` module.
- **DO NOT** put inline shell scripts directly in files (like `systemd.services.*.script`). ALWAYS create a standalone package in the `packages/` directory using `pkgs.writeShellApplication` and declare runtime dependencies explicitly.
- **DO NOT** omit the `...` in Nix module argument lists (e.g. `{ pkgs, config, ... }:`). Always include it for forward compatibility.
- **DO NOT** change `system.stateVersion` or `home.stateVersion` on existing systems unless explicitly requested.
- **DO NOT** run `just check`.
- **DO NOT** assume service data is declarative by default. Check if the module provides a `declarative` option.
- **DO NOT** add a new host without updating `topology.nix`.

## ⚠️ Gotchas & Important Notes
- Many commands use the `--impure` flag by default.
- The project relies heavily on `sops-nix`.
- Network structures are tracked with `nix-topology`.
- Nix files are formatted using `nixfmt-tree`.