# **NixOS Dotfiles (v5)**

[![Deploy Docs](https://github.com/xiro-codes/dotfiles.v5.nix/actions/workflows/docs.yml/badge.svg)](https://github.com/xiro-codes/dotfiles.v5.nix/actions/workflows/docs.yml)
[![Built with Nix](https://img.shields.io/badge/Built_with-Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)

A declarative, multi-host NixOS configuration built with [Nix Flakes](https://nixos.wiki/wiki/Flakes), [flake-parts](https://flake.parts/), and [Home Manager](https://nixos.community/home-manager/). This setup features an automated discovery system that dynamically generates host configurations and modules.

**[📚 Read the Documentation](https://xiro-codes.github.io/dotfiles.v5.nix/)**

## **🚀 Quick Start**

### **Installation**

1. **Boot the Installer**:
   Use the custom ISO provided by this flake:
   ```bash
   nix build .#installer-iso
   ```

2. **Partition & Install**:
   ```bash
   # Using Disko (automated)
   just install-local <hostname>   # Install via local Gitea mirror
   just install-remote <hostname>  # Install via Github source
   ```

3. **Manual Install**:
   ```bash
   # Clone the repo
   git clone https://github.com/xiro-codes/dotfiles.v5.nix /etc/nixos
   cd /etc/nixos

   # Generate hardware config
   nixos-generate-config --show-hardware-config > systems/<hostname>/hardware.nix

   # Install
   nixos-install --flake .#<hostname>
   ```

## **Architecture: Automated Discovery**

This repository utilizes a modular discovery engine (`parts/discovery/`) that scans the file system to build the flake. This eliminates the need to manually register new files in `flake.nix`.

* **Systems**: Every directory in `/systems` containing both a `configuration.nix` and `hardware-configuration.nix` is automatically converted into a `nixosConfiguration`.
* **System Modules**: Found in `/modules/system`. Any directory with a `default.nix` is automatically exported as a NixOS module. Metadata and descriptions can be provided via a `meta.nix` file.
* **Home Modules**: Found in `/modules/home`. These are automatically exported for use within Home Manager. Can also use `meta.nix`.
* **Home Configurations**: Standalone Home Manager configurations are generated from `user@hostname.nix`, `user@hostname/default.nix`, or `hostname/user.nix` configurations in `/home`.
* **Packages**: Custom packages in `/packages` are automatically built for the current system. Inline scripts have been extracted here as well.
* **Dev Shells**: Every directory in `/shells` is automatically exported as a devShell (accessible via `nix develop .#<name>`).
* **Deploy Nodes**: Systems with a `deploy.nix` file are automatically added to `deploy-rs` configuration.
* **Templates**: Project templates in `/templates` are automatically exported (e.g., Rust CLI, Python, Flutter, Bevy, ESP32 Rust).

## **💻 Managed Systems**

### [**Onix**](./systems/Onix/configuration.nix)

* **Role**: Home Server
* **IP**: 192.168.1.65
* **Bootloader**: UEFI with **Limine**
* **Key Features**: Central file server, Gitea instance, media server, and Pi-hole.
* **Hosted Domains**: `dashboard.onix.home`, `git.onix.home`, `tv.onix.home`, `plex.onix.home`, `ch7.onix.home`, `comics.onix.home`, `audiobooks.onix.home`, `dl.onix.home`, `yt.onix.home`, `pihole.onix.home`, `docs.onix.home`, `cache.onix.home`

### [**Ruby**](./systems/Ruby/configuration.nix)

* **Role**: Primary Workstation
* **IP**: 192.168.1.66
* **Bootloader**: UEFI with **Limine**
* **Key Features**: High-performance workstation, local backup management, and comprehensive network share mounts (Music, Books, Backups).

### [**Sapphire**](./systems/Sapphire/configuration.nix)

* **Role**: AI Services & Secondary Workstation
* **IP**: 192.168.1.67
* **Bootloader**: UEFI with **Limine**
* **Key Features**: Local LLM and AI services (Ollama, Open WebUI), remote mounts.
* **Hosted Domains**: `ui.sapphire.home`, `ai.sapphire.home`


### [**Jade**](./systems/containers/Jade/configuration.nix)

* **Role**: Web Services Container
* **Bootloader**: N/A (NixOS Container)
* **Key Features**: DDNS (Cloudflare), SSL management (ACME), Rocket-Forge blog, and Nginx reverse proxy.
* **Hosted Domains**: `tdavis.dev`, `cloud.tdavis.dev`


## **🛠️ Key Modules & Features**

* **Backup Manager**: Automated borg-based backups to /mnt/zima/Backups with smart exclusions for development artifacts (node\_modules, target, .direnv).
* **Secrets Management**: Integrated via sops-nix. Handles sensitive data like SSH keys and API tokens (e.g., Gemini API keys).
* **Desktop Environment**: Both systems default to **Hyprland** with automated theming via **Stylix**.
* **User Manager**: Simplifies user creation and shell (Fish) configuration.
* **Share Manager**: Centralized logic for mounting network storage across nodes.

## **🔒 Secrets Management Guide**

This repository uses `sops-nix` to manage sensitive configuration details like SSH private keys, passwords, and API tokens. All secrets are encrypted and stored in `secrets/secrets.yaml`.

To decrypt secrets, each host uses its SSH host private key (`/etc/ssh/ssh_host_ed25519_key`), and users use their local SOPS SSH key (`~/.ssh/id_sops`).

### **How to Add a Key to SOPS**

To allow a new system host or user to decrypt the repository's secrets, their public key must be converted to age format and added to `.sops.yaml`.

#### **1. Convert the SSH Public Key to Age**
SOPS uses the Age encryption format. Convert the target public SSH key using `ssh-to-age`:
* **For a new host**:
  ```bash
  ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
  ```
* **For a user**:
  ```bash
  ssh-to-age < ~/.ssh/id_sops.pub
  ```

#### **2. Add the Age Key to `.sops.yaml`**
1. Open the `.sops.yaml` file in the root of the repository.
2. Under `keys:`, define a new YAML anchor for the key (using the `age1...` string generated in step 1):
   ```yaml
   keys:
     - &myhost age1gnsqhrf20kx55jpxewp5g9h3u8hffh8tlvstwwett57rp5letu3sndsh9k
   ```
3. Add the anchor alias (`*myhost`) under `creation_rules` -> `key_groups` -> `age`:
   ```yaml
   creation_rules:
     - path_regex: secrets/secrets.yaml
       key_groups:
         - pgp: []
           age:
             - *ruby
             - *sapphire
             # ...
             - *myhost
   ```

#### **3. Re-encrypt the Secrets File**
After modifying `.sops.yaml`, you must update the secrets file so that it is re-encrypted using the new set of keys:
```bash
just update-keys
```
*(This automatically runs `user-sops updatekeys secrets/secrets.yaml` under the hood).*

### **Generating & Registering SSH Keys for a New Host**

When provisioning a new host (e.g., `<hostname>`), you need to generate a set of SSH keys for both the normal user (`tod`) and `root` to enable master identity tracking, GitHub synchronization, and local SOPS decryption. Once generated, these public keys must be registered in the secrets database (`secrets/secrets.yaml`).

#### **1. Generate User Keys (as user `tod`)**
Run the following commands on the new machine:
```bash
# 1. User Master Key (general SSH access)
ssh-keygen -t ed25519 -C "tod@<hostname>" -f ~/.ssh/id_ed25519 -N ""

# 2. User GitHub Key (Git pushing/pulling)
ssh-keygen -t ed25519 -C "github@tdavis.dev" -f ~/.ssh/github -N ""

# 3. User SOPS Key (used by user-sops to decrypt local secrets)
ssh-keygen -t ed25519 -C "tod@<hostname>" -f ~/.ssh/id_sops -N ""
```

#### **2. Generate Root Keys (as `root` or using `sudo`)**
Run the following commands on the new machine:
```bash
# 1. Root Master Key (administrative access)
sudo ssh-keygen -t ed25519 -C "root@<hostname>" -f /root/.ssh/id_ed25519 -N ""

# 2. Root GitHub Key (root-level Git operations)
sudo ssh-keygen -t ed25519 -C "github@tdavis.dev" -f /root/.ssh/github -N ""
```

#### **3. Register the Public Keys in `secrets/secrets.yaml`**
1. On an already authorized machine, open the encrypted secrets file:
   ```bash
   just edit-secrets
   ```
2. Add the public keys for the new host under the corresponding keys structure:
   ```yaml
   ssh_pub_<hostname>:
     master: <contents of ~/.ssh/id_ed25519.pub>
     github: <contents of ~/.ssh/github.pub>
     sops: <contents of ~/.ssh/id_sops.pub>

   ssh_root_<hostname>:
     master: <contents of /root/.ssh/id_ed25519.pub>
     github: <contents of /root/.ssh/github.pub>
   ```
3. Save and exit the editor. SOPS will automatically encrypt the new public keys into `secrets/secrets.yaml`.


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
| just install-local \<host\> | Install a system from local Gitea mirror |
| just install-remote \<host\> | Install a system from Github source |
| just rescue | Quick fix for a borked system (assumes std labels) |
| just bake-recovery | Burn a new ISO to the recovery partition |

### **Dev**

| Command | Action |
| :---- | :---- |
| just run-test | Build and launch the custom Installer ISO in QEMU |
| just clean-test | Clear the test environment |
| just init-undo | Initialize local .undo_dir for Nixvim persistent undo |
| just clear-undos | Clear ephemeral undo directory for current repo |

### **Docs**

| Command | Action |
| :---- | :---- |
| just gen-docs | Generate module documentation to docs/ |
| just serve-docs | Serve docs locally and open in browser |
| just build-docs | Build the static documentation site |
| just view-docs | View docs in terminal |

## **📚 Module Documentation**

All custom modules are documented with auto-generated option references embedded directly into their respective documentation pages.

* [**System Modules**](./docs/system-modules.md) - Orphaned NixOS system module options
* [**Home Modules**](./docs/home-modules.md) - Orphaned Home Manager module options

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
parts/              # Flake logic (Discovery engine, docs, shells)
secrets/            # SOPS-encrypted secrets
shells/             # Development shells (auto-discovered)
systems/            # Host-specific configurations (Ruby, Sapphire)
templates/          # Scaffolding for new modules and projects
```
