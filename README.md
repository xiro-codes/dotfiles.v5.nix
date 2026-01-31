# **NixOS Dotfiles (v5)**

A declarative, multi-host NixOS configuration built with [Nix Flakes](https://www.google.com/search?q=https://nixos.wiki/wiki/Flakes), [flake-parts](https://www.google.com/search?q=https://flake.parts/), and [Home Manager](https://www.google.com/search?q=https://nixos.community/home-manager/). This setup features an automated discovery system that dynamically generates host configurations and modules.

## **🚀 Architecture: Automated Discovery**

This repository utilizes a custom discovery engine (parts/discovery.v2.nix) that scans the file system to build the flake. This eliminates the need to manually register new files in flake.nix.

* **Systems**: Every directory in /systems is automatically converted into a nixosConfiguration.
* **System Modules**: Found in /modules/system. Any directory with a default.nix is automatically exported as a NixOS module.
* **Home Modules**: Found in /modules/home. These are automatically exported for use within Home Manager.
* **Packages**: Custom packages in /packages are automatically built for the current system.
* **User Mapping**: Home Manager is applied to users based on the naming convention user@hostname.nix inside the /home directory.

## **💻 Managed Systems**

### [**Ruby**](https://www.google.com/search?q=./systems/Ruby/configuration.nix)

* **Role**: Primary Workstation
* **IP**: 10.0.0.66
* **Bootloader**: UEFI with **Limine**
* **Key Features**: High-performance workstation, local backup management, and comprehensive network share mounts (Music, Books, Backups).

### [**Sapphire**](https://www.google.com/search?q=./systems/Sapphire/configuration.nix)

* **Role**: Secondary Workstation
* **IP**: 10.0.0.67
* **Bootloader**: UEFI with **systemd-boot**
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
| just switch \<host\> | Switch local system configuration using nh |
| just deploy \<host\> | Deploy to a remote node using deploy-rs |
| just rebuild \<host\> | Standard nixos-rebuild switch (impure) |
| just edit-secrets | Edit encrypted SOPS secrets |
| just run-test | Build and launch the custom Installer ISO in QEMU |
| just init-undo | Initialize local .undo\_dir for Nixvim persistent undo |
| just gc \<host\> | Garbage collect a remote node to free space |

## **💿 Custom Installer**

This flake includes a specialized installer ISO (\#installer-iso) designed for rapid deployment of new nodes.

* **How to use**: Boot the ISO and run sudo install-system \<hostname\> \<user\> \<password\> \[disk\].
* **Features**: Includes a Python-based installation script that automates partitioning and initial flake deployment.

## **📁 Repository Structure**
----
- home/               \# User-specific Home Manager configurations
- modules/
-- home/           \# Reusable Home Manager modules
-- system/         \# Reusable NixOS modules
- packages/           \# Custom Nix packages
- parts/              \# Flake logic (Discovery engine)
- secrets/            \# SOPS-encrypted secrets
- shells/             \# Development shells
- systems/            \# Host-specific configurations (Ruby, Sapphire)
- templates/          \# Scaffolding for new modules and projects
