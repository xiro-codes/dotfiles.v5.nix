{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.local.bootloader;
in
{
  options.local.bootloader = {
    mode = mkOption {
      type = types.enum [
        "uefi"
        "bios"
      ];
      default = "uefi";
      description = "Boot mode: UEFI or legacy BIOS";
    };

    uefiType = mkOption {
      type = types.enum [
        "systemd-boot"
        "grub"
        "limine"
      ];
      default = "systemd-boot";
      description = "UEFI bootloader to use";
    };
    device = mkOption {
      type = types.str;
      default = "";
      example = "/dev/sda";
      description = "Device for BIOS bootloader installation (required for BIOS mode)";
    };
    addRecoveryOption = mkOption {
      type = types.bool;
      default = false;
      description = "Add recovery partition boot option to bootloader menu";
    };
    recoveryUUID = mkOption {
      type = types.str;
      default = "";
      example = "12345678-1234-1234-1234-123456789abc";
      description = "UUID of recovery partition for boot menu entry (use blkid to find partition UUID)";
    };

    enablePlymouth = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Plymouth boot splash screen";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.addRecoveryOption -> cfg.recoveryUUID != "";
        message = "recoveryUUID must be set when addRecoveryOption is enabled";
      }
    ];

    boot.loader = mkMerge [
      (mkIf (cfg.mode == "uefi") {
        systemd-boot.enable = cfg.uefiType == "systemd-boot";
        limine = mkIf (cfg.uefiType == "limine") {
          enable = true;
          maxGenerations = 5;
          extraEntries = mkIf cfg.addRecoveryOption ''
            /Recovery
              protocol:uefi
              path:guid(${cfg.recoveryUUID}):/EFI/BOOT/BOOTX64.EFI
          '';
        };
        grub = mkIf (cfg.uefiType == "grub") {
          enable = true;
          device = "nodev";
          efiSupport = true;
        };
        efi.canTouchEfiVariables = true;
      })
      (mkIf (cfg.mode == "bios") {
        grub = {
          enable = true;
          device = cfg.device;
          efiSupport = false;
        };
      })
    ];

    boot.plymouth.enable = cfg.enablePlymouth;
    boot.kernelParams = mkIf cfg.enablePlymouth [
      "quiet"
      "splash"
    ];
    boot.consoleLogLevel = mkIf cfg.enablePlymouth 0;
    boot.initrd.verbose = mkIf cfg.enablePlymouth false;
  };
}
