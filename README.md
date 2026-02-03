# **NixOS Dotfiles (v5)**

A declarative, multi-host NixOS configuration built with [Nix Flakes](https://nixos.wiki/wiki/Flakes), [flake-parts](https://flake.parts/), and [Home Manager](https://nixos.community/home-manager/). This setup features an automated discovery system that dynamically generates host configurations and modules.

## **🚀 Architecture: Automated Discovery**

This repository utilizes a modular discovery engine (parts/discovery/) that scans the file system to build the flake. This eliminates the need to manually register new files in flake.nix.

* **Systems**: Every directory in /systems is automatically converted into a nixosConfiguration.
* **System Modules**: Found in /modules/system. Any directory with a default.nix is automatically exported as a NixOS module.
* **Home Modules**: Found in /modules/home. These are automatically exported for use within Home Manager.
* **Home Configurations**: Standalone Home Manager configurations are generated from user@hostname.nix files in /home.
* **Packages**: Custom packages in /packages are automatically built for the current system.
* **Deploy Nodes**: Systems with a deploy.nix file are automatically added to deploy-rs configuration.
* **Templates**: Project templates in /templates are automatically exported.

## **💻 Managed Systems**

### [**Ruby**](./systems/Ruby/configuration.nix)

* **Role**: Primary Workstation
* **IP**: 10.0.0.66
* **Bootloader**: UEFI with **Limine**
* **Key Features**: High-performance workstation, local backup management, and comprehensive network share mounts (Music, Books, Backups).

### [**Sapphire**](./systems/Sapphire/configuration.nix)

* **Role**: Secondary Workstation
* **IP**: 10.0.0.67
* **Bootloader**: UEFI with **Limine**
* **Key Features**: Remote mount configuration connecting to a central server (10.0.0.65).

## **🛠️ Key Modules & Features**

* **Backup Manager**: Automated borg-based backups to /mnt/zima/Backups with smart exclusions for development artifacts (node\_modules, target, .direnv).
* **Secrets Management**: Integrated via sops-nix. Handles sensitive data like SSH keys and API tokens (e.g., Gemini API keys).
* **Desktop Environment**: Both systems default to **Hyprland** with automated theming via **Stylix**.
* **User Manager**: Simplifies user creation and shell (Fish) configuration.
* **Share Manager**: Centralized logic for mounting network storage across nodes.

## **⌨️ Command Reference (just)**

The justfile provides several helpers for system administration:

| Command | Action |
| :---- | :---- |
| just | List all available commands |

### **Life (Local System Management)**

| Command | Action |
| :---- | :---- |
| just switch | Switch local system configuration using nh |
| just boot | Set next boot generation using nh |
| just rebuild | Standard nixos-rebuild switch (impure) |

### **Deploy (Remote Management)**

| Command | Action |
| :---- | :---- |
| just deploy \<host\> | Deploy to a remote node using deploy-rs |
| just deploy-all | Deploy all nodes in the flake |
| just check | Safety check before deploying (eval and dry-run) |
| just gc \<host\> | Garbage collect a remote node to free space |

### **Secrets**

| Command | Action |
| :---- | :---- |
| just edit-secrets | Edit encrypted SOPS secrets |
| just update-keys | Update system keys |

### **Backups**

| Command | Action |
| :---- | :---- |
| just init-backup | Initialize borg backup repository |
| just run-backup | Run borg backup manually |
| just mount-backup \<host\> | Mount backup archive to /.recovery |
| just umount-backup | Unmount backup archive |
| just check-timer | Check when next backup is scheduled |
| just list-backups | Show all current backups |

### **Install**

| Command | Action |
| :---- | :---- |
| just install \<host\> | Install a system from scratch using disko |
| just rescue | Quick fix for a borked system (assumes std labels) |
| just bake-recovery | Burn a new ISO to the recovery partition |

### **Dev**

| Command | Action |
| :---- | :---- |
| just run-test | Build and launch the custom Installer ISO in QEMU |
| just clean-test | Clear the test environment |
| just init-undo | Initialize local .undo\_dir for Nixvim persistent undo |
| just clear-undos | Clear ephemeral undo directory for current repo |
| just gen-docs | Generate module documentation to docs/ |

## **📚 Module Documentation**

All custom modules are documented with auto-generated option references:

* [**Module Reference**](./docs/modules.md) - Complete documentation of all custom options
* [**System Modules**](./docs/system-modules.md) - NixOS system module options
* [**Home Modules**](./docs/home-modules.md) - Home Manager module options

To regenerate documentation: `just gen-docs`

## **💿 Custom Installer**

This flake includes a specialized installer ISO (\#installer-iso) for deploying new nodes.

* **How to use**: Boot the ISO and manually partition the target disk, then use `just install <host>` to deploy the configuration.
* **Features**: Includes necessary tools for manual system installation and disko-based automated partitioning.

## **📁 Repository Structure**

```
home/               # User-specific Home Manager configurations
modules/
    home/           # Reusable Home Manager modules
    system/         # Reusable NixOS modules
packages/           # Custom Nix packages
parts/              # Flake logic (Discovery engine)
secrets/            # SOPS-encrypted secrets
shells/             # Development shells
systems/            # Host-specific configurations (Ruby, Sapphire)
templates/          # Scaffolding for new modules and projects
```
