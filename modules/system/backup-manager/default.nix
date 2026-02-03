{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.backup-manager;
  userSubFolders = [
    "Projects"
    "Documents"
    "Pictures"
    "Videos"
    ".ssh"
  ];
  realUsers = lib.filterAttrs
    (
      name: user: user.isNormalUser && user.home != null && (lib.hasPrefix "/home/" user.home)
    )
    config.users.users;
  autoUserPaths = lib.concatMap (user: map (folder: "${user.home}/${folder}") userSubFolders) (
    lib.attrValues realUsers
  );
  finalPaths = lib.unique (autoUserPaths ++ cfg.paths);
in
{
  options.local.backup-manager = {
    enable = lib.mkEnableOption "backup-manager module";
    backupLocation = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/mnt/backups";
      description = "Base path for borg backup repository (must be a mounted filesystem)";
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "/etc/nixos" "/var/lib/important" ];
      description = "Additional paths to backup beyond auto-discovered user folders (Projects, Documents, Pictures, Videos, .ssh)";
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "*/node_modules" "*/target" "*/.cache" "*.tmp" ];
      description = "Glob patterns to exclude from backups";
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs."zima-local" = {
      inherit (cfg) exclude;
      paths = finalPaths;
      repo = cfg.backupLocation + "/${config.networking.hostName}";
      encryption.mode = "none";
      compression = "zstd,1";
      startAt = "daily";
      prune.keep = {
        daily = 7;
        weekly = 4;
      };
    };
    systemd.services.borgbackup-job-zima-local.unitConfig.ConditionPathIsMountPoint =
      cfg.backupLocation;
    environment.etc."backup-manifest.txt".text = ''
      # Backup Manifest for ${config.networking.hostName}
      # Generated: 
      ${lib.concatStringsSep "\n" finalPaths}
    '';
  };
}
