{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = mkDefault true;

  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
}
