HOST := `hostname`

# List available commands
default:
    @just --list

# Build the ISO and launch it immediately
[group('dev')]
run-test:
    nix build .#installer-iso
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

# Generate module documentation
[group('docs')]
gen-docs:
    @echo "📚 Generating module documentation..."
    nix build .#docs
    mkdir -p docs
    cp -f result/README.md docs/modules.md
    cp -f result/system-modules.md docs/system-modules.md
    cp -f result/home-modules.md docs/home-modules.md
    @echo "✅ Documentation generated in docs/"
# Generate docs for a single module using AI and open an editable 2-panel diff
[group('docs')]
gen-mod-doc modname:
    #!/usr/bin/env bash
    set -e

    # 1. Find the module directory
    modpath=""
    if [ -d "modules/system/{{modname}}" ]; then
        modpath="modules/system/{{modname}}"
        type="system"
    elif [ -d "modules/home/{{modname}}" ]; then
        modpath="modules/home/{{modname}}"
        type="home"
    else
        echo "❌ Error: Module '{{modname}}' not found in modules/system/ or modules/home/."
        exit 1
    fi

    target_doc="docs/{{modname}}.md"
    tmp_old="/tmp/old_{{modname}}.md"

    # 2. Back up the existing documentation (or create empty if it's new)
    mkdir -p docs
    if [ -f "$target_doc" ]; then
        cp "$target_doc" "$tmp_old"
    else
        touch "$tmp_old"
    fi

    echo "🤖 Generating docs for $type module: {{modname}}..."

    # 3. Pipe the module code to tgpt-auth
    cat "$modpath/default.nix" | tgpt-auth "Act as a Nix documentation generator.
    Analyze this Nix module and create a detailed Markdown documentation file.
    Include a title (# {{modname}}), a description of what the module does,
    and a list of its options with types and default values.
    be detailed this should act as a guide to refresh myself on things and keep it pretty
    Output ONLY the markdown content." > "$target_doc"

    echo "📖 Opening diff..."

    # 4. Open Neovim in diff mode
    # -R makes the left panel (old version) read-only so you don't accidentally edit the backup
    nvim -R "$tmp_old" -d "$target_doc"

    echo "✅ Finished generating and editing docs for {{modname}}"

# Generate detailed markdown documentation for each module in the docs folder
[group('docs')]
gen-mod-docs:
    #!/usr/bin/env bash
    mkdir -p docs/modules
    for dir in modules/system modules/home; do
        for modpath in "$dir"/*; do
            if [ -d "$modpath" ]; then
                modname=$(basename "$modpath")
                type=$(basename "$dir")
                echo "Generating docs for $type module: $modname..."

                # Pipe the module code to tgpt-auth with specific formatting instructions
                cat "$modpath/default.nix" | tgpt-auth "Act as a Nix documentation generator.
                Analyze this Nix module and create a detailed Markdown documentation file.
                Include a title (# $modname), a description of what the module does,
                and a list of its options with types and default values.
                be detailed this should act as a guide to refresh myself on things and keep it pretty
                Output ONLY the markdown content." > "docs/${modname}.md"
            fi
        done
    done

# Serve docs locally and open in browser
[group('docs')]
serve-docs:
    nix run .#serve-docs

# Generate the network diagram
[group('docs')]
gen-network:
    dot -Tpng docs/network.dot -o docs/network.png

# Build the static documentation site
[group('docs')]
build-docs: gen-network
    nix build .#docs-site
    @echo "✅ Static site built in ./result"

# View docs in terminal
[group('docs')]
view-docs:
    nix run .#view-docs

# Edit system secrets
[group('secrets')]
edit-secrets:
    @user-sops secrets/secrets.yaml

# Update system keys
[group('secrets')]
update-keys:
    @user-sops updatekeys secrets/secrets.yaml

# Initialize backups
[group('backups')]
init-backup:
    sudo borg-job-onix-local init -e none

# Run borg backup
[group('backups')]
run-backup:
    sudo systemctl start borgbackup-job-onix-local.service

# Mount backups
[group('backups')]
mount-backup host=HOST:
    sudo mkdir -p /.recovery
    sudo borg-job-onix-local mount /media/Backups/{{host}}/ /.recovery

# Unmount backups
[group('backups')]
umount-backup:
    sudo umount /.recovery

# Check when next backup is scheduled
[group('backups')]
check-timer:
    systemctl list-timers borgbackup-job-onix-local.timer

# Show all current backups
[group('backups')]
list-backups:
    sudo borg-job-onix-local list

# Deploy specific host using deploy-rs
[group('deploy')]
deploy host=HOST:
    deploy .#{{host}} -- --impure

# Deploy all nodes in the flake
[group('deploy')]
deploy-all:
    deploy . -- --impure

# Safety check before deploying (eval and dry-run)
[group('deploy')]
check:
    nix flake check --impure
    deploy . --dry-activate -- --impure

# Garbage collect a remote node to save space
[group('deploy')]
gc host:
    ssh root@{{host}} 'nix-env --delete-generations old && nix-store --gc'

# Standard nixos-rebuild with impure flag
[group('life')]
rebuild:
    sudo nixos-rebuild switch --flake . --impure

# Switch local system configuration using nh
[group('life')]
switch:
    nh os switch . -- --impure

# Set next boot generation using nh
[group('life')]
boot:
    nh os boot . -- --impure

# Install a system from scratch using disko
[group('install')]
install-local host:
    nix run github:nix-community/disko -- --mode disko --flake .#{{host}}
    mkdir -p /mnt/etc/nixos
    git clone http://10.0.0.65:3002/xiro/dotfiles.nix /mnt/etc/nixos
    nixos-install --flake .#{{host}} --impure

[group('install')]
install-remote host:
    nix run github:nix-community/disko -- --mode disko --flake .#{{host}}
    mkdir -p /mnt/etc/nixos
    git clone https://github.com/xiro-codes/dotfiles.v5.nix /mnt/etc/nixos
    nixos-install --flake .#{{host}} --impure

# Quick fix for a borked system (assumes standard labels)
[group('install')]
rescue:
    mount /dev/disk/by-label/nixos /mnt
    mount /dev/disk/by-label/boot /mnt/boot
    nixos-enter

# Burn a new ISO to the recovery partition
[group('install')]
bake-recovery:
    @echo "Building recovery ISO ..."
    nix build .#installer-iso
    @echo "Burning ISO to recovery partition ..."
    sudo caligula burn $(find result/iso/ -name "*.iso" | head -n 1) -o $(readlink -f /dev/disk/by-partlabel/disk-main-recovery) --interactive never --compression none -f --hash skip
    @echo "Failsafe ISO updated successfully."
