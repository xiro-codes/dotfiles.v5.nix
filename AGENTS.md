# Agent Guide to the NixOS Dotfiles (v5)

This repository is a declarative, multi-host NixOS configuration built with Nix Flakes, flake-parts, and Home Manager. It features an **Automated Discovery System** that dynamically generates host configurations and modules based on the directory structure. 

As an AI agent working in this repository, follow these conventions, patterns, and commands.

## Architecture: Automated Discovery
You **do not** need to manually register new files or modules in `flake.nix`. The discovery engine (`parts/discovery/`) scans the file system to build the flake.

- **`systems/`**: Every directory here is automatically converted into a `nixosConfiguration`.
- **`modules/system/`**: Any directory with a `default.nix` is automatically exported as a NixOS module.
- **`modules/home/`**: Any directory with a `default.nix` is automatically exported for use within Home Manager.
- **`home/`**: Standalone Home Manager configurations are generated from `user@hostname.nix` files.
- **`packages/`**: Custom packages here are automatically built for the current system.
- **`shells/`**: Every directory is exported as a `devShell` (`nix develop .#<name>`).
- **`templates/`**: Project templates are automatically exported.

## Key Technologies & Patterns
- **Secrets Management**: Managed via `sops-nix`. Secrets are stored in `secrets/secrets.yaml`.
- **Backups**: Automated borg-based backups.
- **Desktop Environment**: Hyprland with automated theming via Stylix.
- **Command Runner**: `just` is used for all major operations.

## Essential Commands

The project uses a `justfile` for task management. Run these commands from the repository root:

### Local System Management
- `just switch`: Switch local system configuration using `nh os switch`
- `just boot`: Set next boot generation using `nh os boot`
- `just rebuild`: Standard `nixos-rebuild switch --flake . --impure`

### Deployment & Remote Management
- `just deploy <host>`: Deploy to a remote node using `deploy-rs`
- `just deploy-all`: Deploy all nodes in the flake
- `just check`: Safety check before deploying (eval and dry-run)
- `just gc <host>`: Garbage collect a remote node to free space

### Installation
- `just install <host>`: Install a system from scratch using disko
- `just rescue`: Quick fix for a broken system (mounts labels and enters chroot)
- `just bake-recovery`: Burn a new custom installer ISO to the recovery partition

### Secrets
- `just edit-secrets`: Edit encrypted SOPS secrets
- `just update-keys`: Update system keys

### Development & Testing
- `just run-test`: Build and launch the custom Installer ISO in a QEMU VM
- `just clean-test`: Clear the test environment (removes qcow2 disks, result, etc.)
- `just init-undo` / `just clear-undos`: Manage local undo directories for Nixvim

### Documentation
- `just gen-docs`: Generate module documentation to `docs/`
- `just serve-docs`: Serve docs locally and open in browser
- `just build-docs`: Build the static documentation site
- `just view-docs`: View docs in terminal

## Agent Workflow Guidelines

1. **Adding a Module**: To add a new system or home module, create a new directory inside `modules/system/` or `modules/home/` containing a `default.nix`. The discovery engine will automatically pick it up.
2. **Adding a System**: Create a new folder inside `systems/` containing at least `configuration.nix` and `hardware-configuration.nix`.
3. **Modifying Configurations**: Edit the relevant module or system configuration. Do not touch `flake.nix` unless you are adding a flake input or changing the core discovery logic.
4. **Documentation**: After modifying module options or descriptions, you may be asked to regenerate docs. Run `just gen-docs` to update the Markdown files in `docs/`.
5. **Secrets**: Never write plaintext secrets into the repository files. Secrets should be handled via the `just edit-secrets` flow using SOPS.
