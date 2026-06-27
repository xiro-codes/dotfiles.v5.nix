HOST := `hostname`

# List available commands
default:
    @just --list

# Build the ISO and launch it immediately
[group('dev')]
run-test:
    nix build .#nixosConfigurations.Nucleus.config.system.build.isoImage --impure
    nix run .#test-iso

# Clear the test environment
[group('dev')]
clean-test:
    rm -f test_disk.qcow2
    rm -rf result
    rm -f OVMF_VARS.fd

# Start tracking undo history
[group('dev')]
init-undo:
    @touch .undo
    @echo ".undo_dir/" >> .gitignore
    @echo "✅ Repo initialized. Nixvim will now track undos in .undo_dir/"

# Clear the ephemeral undo directory for the current repo only
[group('dev')]
clear-undos:
    @if [ -d ".undo_dir" ]; then \
        rm -rf .undo_dir/*; \
        echo "🧹 Local .undo_dir files cleared for this repository."; \
    fi

# Edit system secrets
[group('secrets')]
edit-secrets:
    @user-sops secrets/secrets.yaml

# Update system keys
[group('secrets')]
update-keys:
    @user-sops updatekeys secrets/secrets.yaml

# Generate host SSH keys for user and root, and output their public/age keys for registration
[group('secrets')]
gen-keys host=HOST:
    #!/usr/bin/env bash
    set -euo pipefail
    host_lower=$(echo "{{host}}" | tr '[:upper:]' '[:lower:]')
    echo "================================================================================"
    echo "⚡ 1. Generating SSH keys on {{host}}..."
    echo "================================================================================"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -C "tod@{{host}}" -f ~/.ssh/id_ed25519 -N ""
    else
        echo "✅ ~/.ssh/id_ed25519 already exists"
    fi
    if [ ! -f ~/.ssh/github ]; then
        ssh-keygen -t ed25519 -C "github@tdavis.dev" -f ~/.ssh/github -N ""
    else
        echo "✅ ~/.ssh/github already exists"
    fi
    if [ ! -f ~/.ssh/id_sops ]; then
        ssh-keygen -t ed25519 -C "tod@{{host}}" -f ~/.ssh/id_sops -N ""
    else
        echo "✅ ~/.ssh/id_sops already exists"
    fi
    sudo mkdir -p /root/.ssh
    sudo chmod 700 /root/.ssh
    if sudo [ ! -f /root/.ssh/id_ed25519 ]; then
        sudo ssh-keygen -t ed25519 -C "root@{{host}}" -f /root/.ssh/id_ed25519 -N ""
    else
        echo "✅ /root/.ssh/id_ed25519 already exists"
    fi
    if sudo [ ! -f /root/.ssh/github ]; then
        sudo ssh-keygen -t ed25519 -C "github@tdavis.dev" -f /root/.ssh/github -N ""
    else
        echo "✅ /root/.ssh/github already exists"
    fi
    echo ""
    echo "================================================================================"
    echo "🔑 2. PUBLIC KEYS FOR secrets/secrets.yaml"
    echo "================================================================================"
    echo "ssh_pub_${host_lower}:"
    echo "    master: $(cat ~/.ssh/id_ed25519.pub)"
    echo "    github: $(cat ~/.ssh/github.pub)"
    echo "    sops: $(cat ~/.ssh/id_sops.pub)"
    echo "ssh_root_${host_lower}:"
    echo "    master: $(sudo cat /root/.ssh/id_ed25519.pub)"
    echo "    github: $(sudo cat /root/.ssh/github.pub)"
    echo ""
    echo "================================================================================"
    echo "🔒 3. AGE KEYS FOR .sops.yaml"
    echo "================================================================================"
    echo "# Host age key (from /etc/ssh/ssh_host_ed25519_key.pub):"
    if [ -f /etc/ssh/ssh_host_ed25519_key.pub ]; then
        echo "  - &${host_lower} $(nix shell nixpkgs#ssh-to-age -c ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub)"
    else
        echo "  - &${host_lower} <Error: /etc/ssh/ssh_host_ed25519_key.pub not found>"
    fi
    echo "# User SOPS age key (from ~/.ssh/id_sops.pub):"
    echo "  - &tod_${host_lower} $(nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/.ssh/id_sops.pub)"
    echo ""
    echo "================================================================================"
    echo "👉 4. Next steps:"
    echo "================================================================================"
    echo "1. Copy the AGE keys above to the 'keys:' list and 'creation_rules' in .sops.yaml"
    echo "2. Copy the PUBLIC KEYS YAML above into secrets/secrets.yaml (use 'just edit-secrets')"
    echo "3. Run 'just update-keys' to re-encrypt the secrets file with the new keys"
    echo "================================================================================"

# Initialize backups
[group('backups')]
init-backup:
    sudo borg-job-{{HOST}}-local init -e none

# Run borg backup
[group('backups')]
run-backup:
    sudo systemctl start borgbackup-job-{{HOST}}-local.service

# Mount backups
[group('backups')]
mount-backup host=HOST:
    sudo mkdir -p /.recovery
    sudo borg-job-{{HOST}}-local mount /media/Backups/{{host}}/ /.recovery

# Unmount backups
[group('backups')]
umount-backup:
    sudo umount /.recovery

# Check when next backup is scheduled
[group('backups')]
check-timer:
    systemctl list-timers borgbackup-job-{{HOST}}-local.timer

# Show all current backups
[group('backups')]
list-backups:
    sudo borg-job-{{HOST}}-local list

# Build a specific host's configuration
[group('build')]
build host:
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel --impure

# Deploy specific host using deploy-rs
[group('deploy')]
deploy host=HOST:
    deploy -s .#{{host}} -- --impure

# Deploy all nodes in the flake
[group('deploy')]
deploy-all:
    deploy -s . -- --impure

# Safety check before deploying (eval and dry-run)
[group('deploy')]
check:
    nix flake check --impure
    deploy -s . --dry-activate -- --impure

# Garbage collect a remote node to save space
[group('deploy')]
gc host:
    ssh root@{{host}} 'nix-env --delete-generations old && nix-store --gc'

# Standard nixos-rebuild with impure flag
[group('life')]
rebuild:
    sudo nixos-rebuild switch --flake . --impure

[group('life')]
rebuild-no-cache:
    sudo nixos-rebuild switch --flake . --impure --option substituters "https://cache.nixos.org/"

# Switch local system configuration using nh
[group('life')]
switch:
    nh os switch . -- --impure

[group('life')]
switch-no-cache:
    nh os switch . -- --impure --option substituters "https://cache.nixos.org/"

# Set next boot generation using nh
[group('life')]
boot:
    nh os boot . -- --impure

[group('life')]
boot-no-cache:
    nh os boot . -- --impure --option substituters "https://cache.nixos.org/"

# Install a system from scratch using disko
[group('install')]
install-remote host:
    nix run github:nix-community/disko -- --mode mount --flake .#{{host}} || nix run github:nix-community/disko -- --mode disko --flake .#{{host}}
    mkdir -p /mnt/etc/nixos
    git clone https://github.com/xiro-codes/dotfiles.v5.nix /mnt/etc/nixos
    NIXOS_ONBOARDING=1 NIXPKGS_ALLOW_UNFREE=1 nixos-install --flake .#{{host}} --impure

# Quick fix for a borked system (assumes standard labels)
[group('install')]
rescue:
    mount /dev/disk/by-label/nixos /mnt
    mount /dev/disk/by-label/boot /mnt/boot
    nixos-enter

# Burn a new ISO to a disk or the recovery partition
[group('install')]
bake-recovery disk="":
    @echo "Building recovery ISO ..."
    nix build .#nixosConfigurations.Nucleus.config.system.build.isoImage --impure
    @echo "Burning ISO to {{ if disk == "" { "recovery partition" } else { disk } }} ..."
    sudo caligula burn $(find result/iso/ -name "*.iso" | head -n 1) -o {{ if disk == "" { "$(readlink -f /dev/disk/by-partlabel/disk-main-recovery)" } else { disk } }} --interactive never --compression none -f --hash skip
    @echo "Failsafe ISO updated successfully."

# Run a command via ssh on a host
[group('deploy')]
ssh-run host cmd:
    ssh tod@{{host}} '{{cmd}}'

# Generate and show the network topology image
[group('docs')]
gen-topology:
    @echo "Building topology diagrams..."
    nix build .#topology.x86_64-linux.config.output --impure
    @echo "Copying diagrams to root directory..."
    rm -f ./network.svg ./services.svg
    cp result/network.svg ./network.svg
    cp result/main.svg ./services.svg
    @echo "Opening topology images..."
    xdg-open ./network.svg || open ./network.svg || echo "Network image is at ./network.svg"
    xdg-open ./services.svg || open ./services.svg || echo "Services image is at ./services.svg"

# Update external assets manifest
[group('assets')]
update-assets:
    @echo "Updating wallpapers manifest..."
    nix shell nixpkgs#python3 -c python3 packages/wallpapers/update.py
    @echo "Updating icons manifest..."
    nix shell nixpkgs#python3 -c python3 packages/icons/update.py
    @echo "Assets updated successfully."
