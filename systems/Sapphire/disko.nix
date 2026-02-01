{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
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
            # Failsafe ISO partition
            recovery = {
              size = "8G";
              content = {
                type = "filesystem";
                format = "ext4"; # We use ext4 here just to reserve the space
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
    };
  };
}
