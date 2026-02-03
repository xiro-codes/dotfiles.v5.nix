{
  disko.devices = {
    disk = {
      main = {
        device = "TODO";
        type = "disk";
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
                format = "ext4";
                mountpoint = "/";
                extraArgs = [ "-L" "nixos" ];
              };
            };
          };
        };
      };
      ssd0 = {
        type = "table";
        device = "TODO";
        content = {
          type = "gpt";
          partitions = {
            store = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-d raid0 -m raid1 -f" ];
                extraDevices = [ "TODO" "TODO" ];
                subvolumes = {
                  #TODO
                };
              };
            };
          };
        };
      };
      ssd1 = {
        type = "table";
        device = "TODO";
        content = { type = "gpt"; partitions = { storage = { size = "100%"; }; }; };
      };
      ssd2 = {
        type = "table";
        device = "TODO";
        content = { type = "gpt"; partitions = { storage = { size = "100%"; }; }; };
      };


      backup = {
        type = "table";
        device = "TODO";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "TODO";
              };
            };
          };
        };
      };

      media = {
        type = "table";
        device = "TODO";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "TODO";
              };
            };
          };
        };

      };
    };
  };
}
