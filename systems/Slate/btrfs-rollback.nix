{ lib, ... }:

{
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.initrd.systemd.services.btrfs-rollback = {
    description = "Rollback BTRFS root subvolume";
    wantedBy = [ "initrd.target" ];
    after = [ "initrd-root-device.target" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp

      if [ -e /btrfs_tmp/root ]; then
        # Delete nested subvolumes if any exist
        btrfs subvolume list -o /btrfs_tmp/root |
          cut -f9 -d' ' |
          while read subvol; do
            echo "deleting /$subvol subvolume..."
            btrfs subvolume delete "/btrfs_tmp/$subvol"
          done &&
        echo "deleting /root subvolume..." &&
        btrfs subvolume delete /btrfs_tmp/root
      fi

      echo "creating new /root subvolume..."
      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';
  };
}
