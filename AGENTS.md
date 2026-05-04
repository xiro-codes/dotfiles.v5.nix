# Agent Guidelines for NixOS Dotfiles

Welcome to the NixOS Dotfiles (v5) repository. This document provides critical information for AI agents working in this codebase.

## 🏗️ Architecture & Discovery Engine

This repository uses an **external automated discovery engine** via the `inputs-nix` flake. You **do not need to manually register new files or modules in `flake.nix`**. 

When you create a new module, package, or system, place it in the correct directory, and it will be automatically discovered and integrated into the flake outputs.

### Repository Structure
- `systems/<hostname>/`: Host-specific configurations (e.g., Onix, Ruby, Sapphire). Any directory here with a `configuration.nix` and `hardware-configuration.nix` becomes a `nixosConfiguration`. Commonly includes `disko.nix` for declarative disk partitioning and `deploy.nix` for deployment configuration.
- `systems/containers/<container-name>/`: Container configurations (e.g., Amber, Jade). Handled via NixOS containers.
- `modules/system/<module-name>/`: Reusable NixOS modules. Must contain a `default.nix`. A `meta.nix` file is used to provide descriptions for the flake schemas.
- `modules/home/<module-name>/`: Reusable Home Manager modules. Also supports `meta.nix`.
- `home/<user>@<hostname>/`: Standalone Home Manager user configurations. Must contain a `default.nix`. Also supports `meta.nix`.
- `packages/<package-name>/`: Custom Nix packages.
- `shells/<shell-name>/`: Development shells (accessible via `nix develop .#<name>`).
- `templates/<template-name>/`: Flake templates for various languages and project types (e.g., `esp32-rust`, `flutter`, `platformio`, `python-uv`, `rust-cli`, `rust-bevy`, and Nix module/config templates).
- `secrets/`: SOPS-encrypted secrets (`secrets.yaml`).

*Note: The `systems/profiles/` and `home/profiles/` folders are used as imports for reusable configurations, they are not auto-discovered as standalone systems/users.*

## 🛠️ Essential Commands

This project uses `just` as its command runner. **Always use `just` commands when available.**

### Local System Management
- `just switch`: Apply local configuration changes immediately (using `nh`).
- `just boot`: Set configuration for the next boot.
- `just rebuild`: Standard `nixos-rebuild switch --flake . --impure`.

### Remote Deployment & Host Management
- `just deploy <host>`: Deploy to a remote node using `deploy-rs`.
- `just deploy-all`: Deploy all nodes.
- `just gc <host>`: Trigger nix store garbage collection on a remote node.
- **DO NOT RUN** `just check`: Checking flake evaluation can be problematic/forbidden.

### Development & Testing
- `just run-test`: Build and launch the custom Installer ISO in a QEMU VM. Very useful for testing configurations safely.
- `just clean-test`: Clean up the test VM environment (`result`, `test_disk.qcow2`, etc).
- `just init-undo`: Initialize Nixvim undo tracking in `.undo_dir`.
- `just clear-undos`: Clear the ephemeral Nixvim undo directory.

### Secrets Management
- `just edit-secrets`: Edit the SOPS-encrypted secrets file (`secrets/secrets.yaml`).
- `just update-keys`: Update system keys for SOPS.

### Visualization
- `nix-topology`: The flake integrates with `nix-topology` (see `topology.nix`) to map network architecture.

### Backups (Borg)
- `just init-backup`: Initialize local borg backups.
- `just run-backup`: Trigger a borg backup manually via systemd service.
- `just mount-backup host=<host>`: Mount a backup to `/.recovery` for inspection/restoration.
- `just umount-backup`: Unmount the recovery backup.
- `just list-backups`: Show all current backups.
- `just check-timer`: Check the next scheduled backup time.

### Installation & Recovery
- `just install-local <host>`: Install the OS on the local machine using Disko and clone the git repo.
- `just install-remote <host>`: Install the OS similarly but clones from Github.
- `just rescue`: Quick script to mount borked system disks for an existing NixOS label.
- `just bake-recovery`: Builds the installer-iso and burns it to a local recovery partition.

## 📝 Conventions & Patterns

1. **Modules**: System and Home modules typically have a `default.nix` and an optional `meta.nix` describing options. The descriptions in `meta.nix` are surfaced in the flake schemas.
2. **Secrets**: Never hardcode secrets in Nix files. Use `sops-nix` and reference the secrets configured in `secrets/secrets.yaml`. 
3. **Deployments**: Systems with a `deploy.nix` file inside their host directory are automatically added to `deploy-rs` configuration.
4. **Purity**: Many commands (like `nixos-rebuild` and `deploy`) use the `--impure` flag by default.
5. **System Discovery**: System definitions are automatically loaded if the folder contains both `configuration.nix` and `hardware-configuration.nix`.
6. **Topology**: Network structures are tracked with `nix-topology`. Check `topology.nix` for definitions.
7. **Styling**: Nix files are formatted using `nixfmt-tree`. Keep the style clean and readable, matching the surrounding code.
8. **Scripts**: Prefer `pkgs.writeShellApplication` over `pkgs.writeShellScriptBin` for custom packages and shell scripts.

## ⚠️ Gotchas & Important Notes

- **DO NOT** run `just check`.
- **DO NOT** edit `flake.nix` to add a new system or module. Just create the directory in the right place.
- The project relies heavily on `sops-nix`. If you need to add a new secret, you must use `just edit-secrets`.
- To test changes without affecting the host, leverage `just run-test` to spin up the changes in a VM.