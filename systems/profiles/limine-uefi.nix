# Limine UEFI profile - Common bootloader configuration
{ ... }:
{
  local.bootloader = {
    mode = "uefi";
    uefiType = "limine";
    device = "/dev/nvme0n1";
    addRecoveryOption = true;
  };
}
