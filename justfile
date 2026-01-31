# List available commands
default:
    @just --list

# Rebuild the system (Your existing nxs logic) (BROKEN)
nxs:
    nh os switch .

# Create a new Host system (BROKEN)
new-host name:
    mkdir -p systems/{{name}}
    cp templates/system-config.nix systems/{{name}}/configuration.nix
    echo "Created new host: {{name}}. Don't forget to run 'nixos-generate-config' for hardware!"

# Create a new Home user config for a host (BROKEN)
new-home user host:
    cp templates/home-user.nix home/{{user}}@{{host}}.nix
    sed -i 's/TEMPLATE_USER/{{user}}/' home/{{user}}@{{host}}.nix
    echo "Created home config for {{user}} on {{host}}"

# Create a new System Module (BROKEN)
new-sys-mod name:
    mkdir -p modules/system/{{name}}
    cp templates/module.nix modules/system/{{name}}/default.nix
    sed -i 's/TEMPLATE_NAME/{{name}}/' modules/system/{{name}}/default.nix
    echo "Created system module: {{name}}"

# Create a new Home Module (BROKEN)
new-home-mod name:
    mkdir -p modules/home/{{name}}
    cp templates/module.nix modules/home/{{name}}/default.nix
    sed -i 's/TEMPLATE_NAME/{{name}}/' modules/home/{{name}}/default.nix
    echo "Created home module: {{name}}"

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

run-backup:
  sudo systemctl start borgbackup-job-zima-local.service

check-timer:
  systemctl list-timers borgbackup-job-zima-local.timer

list-backups:
  sudo borg-job-zima-local list

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
deploy host:
    deploy .#{{host}}

# Deploy all nodes in the flake
deploy-all:
    deploy .

# Safety check before deploying (Eval and dry-run)
check:
    nix flake check
    deploy . --dry-activate

# Check the current health/generation of all nodes
status:
    deploy . --version

# Garbage collect the remote node to save space
gc host:
    ssh root@{{host}} 'nix-env --delete-generations old && nix-store --gc'
