{ config, lib, pkgs, ... }:

let
  cfg = config.local.bootloader;
in
{
  options.local.bootloader = {
    mode = lib.mkOption {
      type = lib.types.enum [ "uefi" "bios" ];
      default = "uefi";
      description = "Boot mode: UEFI or legacy BIOS";
    };

    uefiType = lib.mkOption {
      type = lib.types.enum [ "systemd-boot" "grub" "limine" ];
      default = "systemd-boot";
      description = "UEFI bootloader to use";
    };
    device = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/dev/sda";
      description = "Device for BIOS bootloader installation (required for BIOS mode)";
    };
    addRecoveryOption = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Add recovery partition boot option to bootloader menu";
    };
    recoveryUUID = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "12345678-1234-1234-1234-123456789abc";
      description = "UUID of recovery partition for boot menu entry (use blkid to find partition UUID)";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.addRecoveryOption -> cfg.recoveryUUID != "";
        message = "recoveryUUID must be set when addRecoveryOption is enabled";
      }
    ];

    boot.loader = lib.mkMerge [
      (lib.mkIf (cfg.mode == "uefi") {
        systemd-boot.enable = cfg.uefiType == "systemd-boot";
        limine = lib.mkIf (cfg.uefiType == "limine") {
          enable = true;
          maxGenerations = 5;
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
