{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.local.disks = {
    enable = mkEnableOption "basic configuration for disk management";
  };
  config = mkIf config.local.disks.enable {
    services = {
      gvfs.enable = true;
      udisks2.enable = true;
      devmon.enable = true;
    };
  };
}
