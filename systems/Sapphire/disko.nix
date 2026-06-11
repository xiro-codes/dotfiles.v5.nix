{
  disko.devices = {
    disk = {
      boot_nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4e21ddac";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [ "-n" "boot" ];
              };
            };
            recovery = {
              size = "8G";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [ "-L" "recovery" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = [ "-L" "nixos" ];
              };
            };
          };
        };
      };
      
      nix_nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0025385651408688";
        content = {
          type = "gpt";
          partitions.raid_part = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "nix_raid";
            };
          };
        };
      };
      nix_nvme2 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0025385651408667";
        content = {
          type = "gpt";
          partitions.raid_part = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "nix_raid";
            };
          };
        };
      };

      /*
      media_hdd = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5000c500e3673662";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/media/Media";
              };
            };
          };
        };
      };
      */

      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5000039fdcc29995";
        content = {
          type = "gpt";
          partitions.raid_part = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "backup_raid";
            };
          };
        };
      };
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50014ee269a3bd34";
        content = {
          type = "gpt";
          partitions.raid_part = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "backup_raid";
            };
          };
        };
      };
      hdd3 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50014ee210be737f";
        content = {
          type = "gpt";
          partitions.raid_part = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "backup_raid";
            };
          };
        };
      };

      ssd1 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5002538ed09e2f5f";
        content = {
          type = "gpt";
          partitions.raid_part = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "ssd_raid";
            };
          };
        };
      };
      ssd2 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5002538ec04e4f49";
        content = {
          type = "gpt";
          partitions.raid_part = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "ssd_raid";
            };
          };
        };
      };
    };

    mdadm = {
      nix_raid = {
        type = "mdadm";
        level = 0;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/nix";
          extraArgs = [ "-L" "nix-store" ];
        };
      };
      backup_raid = {
        type = "mdadm";
        level = 5;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/media/Backups";
          extraArgs = [ "-L" "backups" ];
        };
      };
      ssd_raid = {
        type = "mdadm";
        level = 0;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/media/Scratch";
          extraArgs = [ "-L" "scratch" ];
        };
      };
    };
  };
}
