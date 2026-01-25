{ pkgs, ... }:

pkgs.writeShellScriptBin "test-iso" ''
  # Find any ISO in the result directory
  ISO_PATH=$(find result/iso -name "*.iso" | head -n 1)
  DISK_PATH="./test_disk.qcow2"
  
  if [ -z "$ISO_PATH" ]; then
    echo "❌ No ISO found in result/iso! Run 'nix build .#installer-iso' first."
    exit 1
  fi

  echo "📂 Found ISO: $ISO_PATH"

  # Create a 20GB virtual disk if it doesn't exist
  if [ ! -f "$DISK_PATH" ]; then
    echo "📦 Creating 20GB virtual disk..."
    ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$DISK_PATH" 20G
  fi

  echo "🚀 Launching VM..."
  # -boot menu=on: allows you to press F12 to select boot device
  # -net nic,model=virtio: faster networking for the Git push test
  ${pkgs.qemu}/bin/qemu-system-x86_64 \
    -enable-kvm \
    -m 4G \
    -smp 4 \
    -drive if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.fd}/FV/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=${pkgs.OVMF.fd}/FV/OVMF_VARS.fd \
    -drive file="$DISK_PATH",format=qcow2,if=virtio \
    -cdrom "$ISO_PATH" \
    -boot d \
    -net nic,model=virtio -net user \
    -vga virtio \
    -display gtk,gl=on
''
