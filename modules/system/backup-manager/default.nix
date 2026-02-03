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
      description = "Base path for borg backup repository";
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional paths to backup beyond auto-discovered user folders";
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Patterns to exclude from backups (e.g., node_modules, target)";
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
