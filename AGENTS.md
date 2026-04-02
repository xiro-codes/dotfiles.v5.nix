# Agent Guidelines for NixOS Dotfiles

Welcome to the NixOS Dotfiles (v5) repository. This document provides critical information for AI agents working in this codebase.

## 🏗️ Architecture & Discovery Engine

This repository uses a **custom automated discovery engine** (`parts/discovery/`) based on `flake-parts`. You **do not need to manually register new files or modules in `flake.nix`**. 

When you create a new module, package, or system, place it in the correct directory, and it will be automatically discovered and integrated into the flake outputs.

### Repository Structure
- `systems/<hostname>/`: Host-specific configurations (e.g., Onix, Ruby, Sapphire). Any directory here becomes a `nixosConfiguration`.
- `modules/system/<module-name>/`: Reusable NixOS modules. Must contain a `default.nix`.
- `modules/home/<module-name>/`: Reusable Home Manager modules.
- `home/<user>@<hostname>.nix`: Standalone Home Manager user configurations.
- `packages/<package-name>/`: Custom Nix packages.
- `shells/<shell-name>/`: Development shells (accessible via `nix develop .#<name>`).
- `secrets/`: SOPS-encrypted secrets.

## 🛠️ Essential Commands

This project uses `just` as its command runner. **Always use `just` commands when available.**

### Local System Management
- `just switch`: Apply local configuration changes immediately (using `nh`).
- `just boot`: Set configuration for the next boot.
- `just rebuild`: Standard `nixos-rebuild switch --flake . --impure`.

### Remote Deployment
- `just deploy <host>`: Deploy to a remote node using `deploy-rs`.
- `just deploy-all`: Deploy all nodes.
- `just check`: Check flake evaluation before deploying.

### Development & Testing
- `just run-test`: Build and launch the custom Installer ISO in a QEMU VM. Very useful for testing configurations safely.
- `just clean-test`: Clean up the test VM environment.

### Secrets Management
- `just edit-secrets`: Edit the SOPS-encrypted secrets file (`secrets/secrets.yaml`).
- `just update-keys`: Update system keys for SOPS.

### Documentation
- `just gen-docs`: Generate module documentation to the `docs/` folder.
- `just gen-mod-doc <modname>`: Use AI (`tgpt-auth`) to generate docs for a specific module and open a diff.

## 📝 Conventions & Patterns

1. **Modules**: System and Home modules typically have a `default.nix` and an optional `meta.nix` (or similar) describing options. 
2. **Secrets**: Never hardcode secrets in Nix files. Use `sops-nix` and reference the secrets configured in `secrets/secrets.yaml`. 
3. **Deployments**: Systems with a `deploy.nix` file inside their host directory are automatically added to `deploy-rs` configuration.
4. **Purity**: Many commands (like `nixos-rebuild` and `deploy`) use the `--impure` flag by default.

## ⚠️ Gotchas & Important Notes

- **DO NOT** edit `flake.nix` to add a new system or module. Just create the directory in the right place.
- **DO NOT** edit generated documentation in `docs/` directly without running the generation scripts, as they may get overwritten. 
- The project relies heavily on `sops-nix`. If you need to add a new secret, you must use `just edit-secrets`.
- To test changes without affecting the host, leverage `just run-test` to spin up the changes in a VM.
