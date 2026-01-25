{ pkgs, ... }:

pkgs.writeShellScriptBin "test-iso" ''
  # Find the ISO
  ISO_PATH=$(find result/iso -name "*.iso" | head -n 1)
  DISK_PATH="./test_disk.qcow2"
  VARS_PATH="./OVMF_VARS.fd"
  
  if [ -z "$ISO_PATH" ]; then
    echo "❌ No ISO found! Run 'nix build .#installer-iso' first."
    exit 1
  fi

  # 1. Create a writable copy of UEFI variables if it doesn't exist
  if [ ! -f "$VARS_PATH" ]; then
    echo "📂 Creating writable UEFI variables..."
    cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd "$VARS_PATH"
    chmod +w "$VARS_PATH"
  fi

  # 2. Create virtual disk
  if [ ! -f "$DISK_PATH" ]; then
    echo "📦 Creating 20GB virtual disk..."
    ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$DISK_PATH" 20G
  fi

  echo "🚀 Launching VM..."
  ${pkgs.qemu}/bin/qemu-system-x86_64 \
    -enable-kvm \
    -m 4G \
    -smp 4 \
    -drive if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.fd}/FV/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file="$VARS_PATH" \
    -drive file="$DISK_PATH",format=qcow2,if=virtio \
    -cdrom "$ISO_PATH" \
    -boot d \
    -net nic,model=virtio -net user \
    -vga virtio \
    -display gtk,gl=on
''
