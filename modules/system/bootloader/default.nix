{ config, lib, pkgs, ... }:

let
  cfg = config.local.bootloader;
in
{
  options.local.bootloader = {
    mode = lib.mkOption {
      type = lib.types.enum [ "uefi" "bios" ];
      default = "uefi";
    };
    uefiType = lib.mkOption {
      type = lib.types.enum [ "systemd-boot" "grub" "limine" ];
      default = "systemd-boot";
    };
    device = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    addRecoveryOption = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    recoveryUUID = lib.mkOption {
      type = lib.types.str;
      default = "0d9dddd8-9511-4101-9177-0a80cfbeb047";
    };
  };

  config = {
    boot.loader = lib.mkMerge [
      (lib.mkIf (cfg.mode == "uefi") {
        systemd-boot.enable = cfg.uefiType == "systemd-boot";
        limine = lib.mkIf (cfg.uefiType == "limine") {
          enable = true;
          extraEntries = lib.mkIf cfg.addRecoveryOption ''
            /Recovery
              protocol:uefi 
              path:guid(${cfg.recoveryUUID}):/EFI/BOOT/BOOTX64.EFI
          '';
        };
        grub = lib.mkIf (cfg.uefiType == "grub") {
          enable = true;
          device = "nodev";
          efiSupport = true;
        };
        efi.canTouchEfiVariables = true;
      })
      (lib.mkIf (cfg.mode == "bios") {
        grub = {
          enable = true;
          device = cfg.device;
          efiSupport = false;
        };
      })
    ];
  };
}
