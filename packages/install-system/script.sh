#!/usr/bin/env bash
set -e

# Args
HOSTNAME=$1
DESKTOP=$2
USER=$3
PASS=$4
OVERRIDE_DISK=$5

if [ -z "$PASS" ]; then
    echo "Usage: install-system <host> <desktop> <user> <pass> [disk_path]"
    exit 1
fi

# 1. Drive Detection / Override
if [ -n "$OVERRIDE_DISK" ]; then
    DISK=$OVERRIDE_DISK
else
    DISK=$(lsblk -dno NAME,TYPE,TRAN | awk '$2=="disk" {print "/dev/"$1}' | grep nvme | head -n1)
    [ -z "$DISK" ] && DISK=$(lsblk -dno NAME,TYPE | awk '$2=="disk" {print "/dev/"$1}' | head -n1)
fi

# --- PRE-FLIGHT CHECK ---
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 NIXOS INSTALLER: PRE-FLIGHT CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📍 TARGET DISK:   $DISK"
echo "  🏷️  HOSTNAME:      $HOSTNAME"
echo "  🖥️  DESKTOP:       $DESKTOP"
echo "  👤 USERNAME:      $USER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
lsblk "$DISK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "⚠️  PROCEED WITH FORMATTING? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled."
    exit 1
fi

# 2. Partition & Format
echo "🏗️  Wiping and Partitioning $DISK..."
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary ext4 512MiB 100%

[[ "$DISK" == *"nvme"* ]] && P="p" || P=""
PART_BOOT="${DISK}${P}1"
PART_ROOT="${DISK}${P}2"

mkfs.fat -F32 "$PART_BOOT"
mkfs.ext4 -L nixos "$PART_ROOT"

# 3. Mount
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount "$PART_BOOT" /mnt/boot

# 4. Repo Setup
echo "📂 Cloning local repository with full history..."
mkdir -p /mnt/etc
cp -r /etc/dotfiles-src /mnt/etc/dotfiles
chmod -R u+w /mnt/etc/dotfiles
cd /mnt/etc/dotfiles

# 5. Generate dynamic configs
echo "📝 Generating host files..."
sed "s/TEMPLATE_USER/$USER/g; s/TEMPLATE_DESKTOP/$DESKTOP/g" templates/host-home.nix > "home/$USER@$HOSTNAME.nix"
mkdir -p "systems/x86_64-linux/$HOSTNAME"
sed "s/TEMPLATE_USER/$USER/g; s/TEMPLATE_DESKTOP/$DESKTOP/g; s/TEMPLATE_PASS/$PASS/g" templates/host-system.nix > "systems/x86_64-linux/$HOSTNAME/configuration.nix"

# 6. Hardware scan
nixos-generate-config --root /mnt --output "systems/x86_64-linux/$HOSTNAME/hardware-configuration.nix"

# 7. Final Install
git add .
git commit -m "Bootstrap $HOSTNAME on $DISK"
nixos-install --flake ".#$HOSTNAME"

# 8. Post-Install Report
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🏁 INSTALLATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📄 GENERATED HOME CONFIG (home/$USER@$HOSTNAME.nix):"
cat "home/$USER@$HOSTNAME.nix"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📄 GENERATED SYSTEM CONFIG (systems/x86_64-linux/$HOSTNAME/configuration.nix):"
cat "systems/x86_64-linux/$HOSTNAME/configuration.nix"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 9. Reboot Timer
echo -n "Rebooting in 30 seconds... (Press any key to stay in shell) "
if read -t 30 -n 1; then
    echo -e "\n🛑 Auto-reboot cancelled. You are now in the chroot environment."
    echo "When finished, type 'reboot' to restart."
else
    echo -e "\n👋 Rebooting now..."
    reboot
fi
