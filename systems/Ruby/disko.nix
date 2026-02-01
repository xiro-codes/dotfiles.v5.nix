{ device ? "/dev/nvme0n1", ... }: {
  disko.devices = {
    disk = {
      main = {
        inherit device;

        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M"; # 1GB is better for modern NixOS (lots of kernels)
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
