{
  disko.devices = {
    mdadm = {
    	raid0 = {
		type = "mdadm";
		level = 0;
		content = {
			type = "gpt";
			partitions = {
				storage = {
					size = "100%";
					content = {
						type = "filesystem";
						format = "ext4";
						#mountpoint = "/media/"
					};
				};
			};
		};
	};
    };
    disk = {
      main = {
        device = "/dev/nvme3n1";
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
	      	type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = [ "-L" "nixos" ];
              };
            };
          };
        };
      };
      ssd0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
	      	type = "mdraid";
		name = "raid0";
              };
            };
          };
        };
      };
      ssd1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = { type = "gpt"; partitions = { storage = { size = "100%";  content = {type = "mdraid"; name = "raid0";};}; }; };
      };
      ssd2 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = { type = "gpt"; partitions = { storage = { size = "100%";  content = {type = "mdraid"; name = "raid0";};}; }; };
      };


      backup = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/media/Backups";
              };
            };
          };
        };
      };

      media = {
        type = "disk";
        device = "/dev/sdb";
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
    };
  };
}
