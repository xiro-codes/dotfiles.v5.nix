{ config, lib, pkgs, ... }: {
  options.local.disks = {
    enable = lib.mkEnableOption "basic configuration for disk management";
  };
  config = lib.mkIf config.local.disks.enable
    {
      services = {
        gvfs.enable = true;
        udisk2.enable = true;
        devmon.enable = true;
      };
    };
}
