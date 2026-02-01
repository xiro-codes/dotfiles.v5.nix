HOST := `hostname`

# List available commands
default:
    @just --list

# Build the ISO and launch it immediately
run-test:
    nix build .#installer-iso
    nix run .#test-iso

# Clear the test environment
clean-test:
    rm -f test_disk.qcow2
    rm -rf result
    rm -f OVMF_VARS.fd

#Edit system secrets
edit-secrets:
  @user-sops secrets/secrets.yaml

#Update system keys
update-keys:
  @user-sops updatekeys secrets/secrets.yaml

#init backups
init-backup:
  sudo borg-job-zima-local init -e none

# run borg backup
run-backup:
  sudo systemctl start borgbackup-job-zima-local.service

# check when next backup is run
check-timer:
  systemctl list-timers borgbackup-job-zima-local.timer

# show all current backups
list-backups:
  sudo borg-job-zima-local list

# start tracking undo history
init-undo:
  @touch .undo
  @echo ".undo_dir/" >> .gitignore
  @echo "✅ Repo initialized. Nixvim will now track undos in .undo_dir/"

# Clear the ephemeral undo directory for the CURRENT repo only
clear-undos:
    @if [ -d ".undo_dir" ]; then \
        rm -rf .undo_dir/*; \
        echo "🧹 Local .undo_dir files cleared for this repository."; \
    fi

# Deploy specific host using deploy-rs (Deploys from local disk)
deploy host=HOST:
    deploy .#{{host}} -- --impure

# Deploy all nodes in the flake
deploy-all:
    deploy . -- --impure

# Safety check before deploying (Eval and dry-run)
check:
    nix flake check --impure
    deploy . --dry-activate -- --impure

# Check the current health/generation of all nodes
status:
    deploy . --version

# Garbage collect the remote node to save space
gc host=HOST:
    ssh root@{{host}} 'nix-env --delete-generations old && nix-store --gc'

# Standard nixos-rebuild with impure flag
rebuild host=HOST:
    sudo nixos-rebuild switch --flake .#{{host}} --impure

# nh wrapper for better UI, also passing through the impure flag
switch host=HOST:
    nh os switch . -- --impure

# install a system from scratch using disko
install host:
  nix run github:nix-community/disko -- --mode disko --flake .#{{host}}
  mkdir -p /mnt/etc/nixos
  git clone http://10.0.0.65:3002/xiro/dotfiles.nix /mnt/etc/nixos
  nixos-install --flake .#{{host}}

# quick fix for a borked system ( assumes std labels )
rescue:
  mount /dev/disk/by-label/nixos /mnt
  mount /dev/disk/by-label/boot /mnt/boot
  nixos-enter
