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

#Edit system secrets
[group('Secrets')]
edit-secrets:
  @user-sops secrets/secrets.yaml

#Update system keys
[group('Secrets')]
update-keys:
  @user-sops updatekeys secrets/secrets.yaml

#init backups
[group("Backups")]
init-backup:
  sudo borg-job-zima-local init -e none

# run borg backup
[group("Backups")]
run-backup:
  sudo systemctl start borgbackup-job-zima-local.service

# mount backups
[group("Backups")]
mount-backup host=HOST:
  sudo mkdir -p /.recovery
  sudo borg-job-zima-local mount /mnt/zima/Backups/{{host}}/ /.recovery

# unmount backups
[group("Backups")]
umount-backup:
  sudo umount /.recovery

# check when next backup is run
[group("Backups")]
check-timer:
  systemctl list-timers borgbackup-job-zima-local.timer

# show all current backups
[group("Backups")]
list-backups:
  sudo borg-job-zima-local list

# start tracking undo history
[group("dev")]
init-undo:
  @touch .undo
  @echo ".undo_dir/" >> .gitignore
  @echo "✅ Repo initialized. Nixvim will now track undos in .undo_dir/"

# Clear the ephemeral undo directory for the CURRENT repo only
[group("dev")]
clear-undos:
    @if [ -d ".undo_dir" ]; then \
        rm -rf .undo_dir/*; \
        echo "🧹 Local .undo_dir files cleared for this repository."; \
    fi

# Deploy specific host using deploy-rs (Deploys from local disk)
[group("deploy")]
deploy host=HOST:
    deploy .#{{host}} -- --impure

# Deploy all nodes in the flake
[group("deploy")]
deploy-all:
    deploy . -- --impure

# Safety check before deploying (Eval and dry-run)
[group("deploy")]
check:
    nix flake check --impure
    deploy . --dry-activate -- --impure

# Check the current health/generation of all nodes
[group("deploy")]
status:
    deploy . --version

# Garbage collect the remote node to save space
[group("deploy")]
gc host=HOST:
    ssh root@{{host}} 'nix-env --delete-generations old && nix-store --gc'

# Standard nixos-rebuild with impure flag
[group("life")]
rebuild host=HOST:
    sudo nixos-rebuild switch --flake .#{{host}} --impure

# nh wrapper for better UI, also passing through the impure flag
[group("life")]
switch host=HOST:
    nh os switch . -- --impure

# nh wrapper for better UI,
[group("life")]
boot host=HOST:
    nh os boot . -- --impure

# install a system from scratch using disko
[group("install")]
install host:
  nix run github:nix-community/disko -- --mode disko --flake .#{{host}}
  mkdir -p /mnt/etc/nixos
  git clone http://10.0.0.65:3002/xiro/dotfiles.nix /mnt/etc/nixos
  nixos-install --flake .#{{host}} --impure

# quick fix for a borked system ( assumes std labels )
[group("install")]
rescue:
  mount /dev/disk/by-label/nixos /mnt
  mount /dev/disk/by-label/boot /mnt/boot
  nixos-enter

# burn a new iso to the recovery partition
[group("install")]
bake-recovery:
  @echo "Building recovery ISO ..."
  nix build .#installer-iso
  @echo "Burning ISO to recovery partition ..."
  sudo caligula burn $(find result/iso/ -name "*.iso" | head -n 1) -o $(readlink -f /dev/disk/by-partlabel/disk-main-recovery) --interactive never --compression none -f --hash skip
  @echo "Failsafe ISO updated successfully."
