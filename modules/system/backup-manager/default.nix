{ config, lib, pkgs, ... }:

let
  cfg = config.local.backup-manager;
in
{
  options.local.backup-manager = {
    enable = lib.mkEnableOption "backup-manager module";
    backupLocation = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs."zima-local" = {
      inherit (cfg) paths exclude;
      repo = cfg.backupLocation + "/${config.networking.hostName}";
      encryption.mode = "none";
      compression = "zstd,1";
      startAt = "daily";
      prune.keep = {
        daily = 7;
        weekly = 4;
      };
    };
    systemd.services.borgbackup-job-zima-local.unitConfig.ConditionPathIsMountPoint = cfg.backupLocation;
  };
}
