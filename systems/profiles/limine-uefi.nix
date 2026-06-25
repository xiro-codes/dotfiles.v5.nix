# Limine UEFI profile - Common bootloader configuration
{ lib, ... }:
{
  local.bootloader = {
    mode = "uefi";
    uefiType = "limine";
    device = "/dev/nvme0n1";
    addRecoveryOption = lib.mkDefault true;
  };
}
