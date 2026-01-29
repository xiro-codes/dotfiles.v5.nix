# List available commands
default:
    @just --list

# Rebuild the system (Your existing nxs logic)
nxs:
    nh os switch .

# Create a new Host system
new-host name:
    mkdir -p systems/{{name}}
    cp templates/system-config.nix systems/{{name}}/configuration.nix
    echo "Created new host: {{name}}. Don't forget to run 'nixos-generate-config' for hardware!"

# Create a new Home user config for a host
new-home user host:
    cp templates/home-user.nix home/{{user}}@{{host}}.nix
    sed -i 's/TEMPLATE_USER/{{user}}/' home/{{user}}@{{host}}.nix
    echo "Created home config for {{user}} on {{host}}"

# Create a new System Module
new-sys-mod name:
    mkdir -p modules/system/{{name}}
    cp templates/module.nix modules/system/{{name}}/default.nix
    sed -i 's/TEMPLATE_NAME/{{name}}/' modules/system/{{name}}/default.nix
    echo "Created system module: {{name}}"

# Create a new Home Module
new-home-mod name:
    mkdir -p modules/home/{{name}}
    cp templates/module.nix modules/home/{{name}}/default.nix
    sed -i 's/TEMPLATE_NAME/{{name}}/' modules/home/{{name}}/default.nix
    echo "Created home module: {{name}}"

# Build the ISO and launch it immediately
test:
    nix build .#installer-iso
    nix run .#test-iso

# Clear the test environment
clean-test:
    rm -f test_disk.qcow2
    rm -rf result/

#Edit system secrets
secrets:
  sops secrets/secrets.yaml

update-keys:
  @echo "Update your .sops.yaml with the public keys from /etc/ssh/ssh_host_ed25519_key.pub"

