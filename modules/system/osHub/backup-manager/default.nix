{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrValues
    concatMap
    concatStringsSep
    filterAttrs
    hasPrefix
    mkEnableOption
    mkIf
    mkOption
    types
    unique
    ;

  cfg = config.local.backup-manager;
  userSubFolders = [
    "Projects"
    "Documents"
    "Pictures"
    "Videos"
    ".ssh"
  ];
  realUsers = filterAttrs (
    name: user: user.isNormalUser && user.home != null && (hasPrefix "/home/" user.home)
  ) config.users.users;
  autoUserPaths = concatMap (user: map (folder: "${user.home}/${folder}") userSubFolders) (
    attrValues realUsers
  );
  finalPaths = unique (autoUserPaths ++ cfg.paths);
in
{
  options.local.backup-manager = {
    enable = mkEnableOption "backup-manager module";
    backupLocation = mkOption {
      type = types.str;
      default = "";
      example = "/media/Backups";
      description = "Base path for borg backup repository (must be a mounted filesystem)";
    };
    paths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "/etc/nixos"
        "/var/lib/important"
      ];
      description = "Additional paths to backup beyond auto-discovered user folders (Projects, Documents, Pictures, Videos, .ssh)";
    };
    exclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "*/node_modules"
        "*/target"
        "*/.cache"
        "*.tmp"
      ];
      description = "Glob patterns to exclude from backups";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.backupLocation != "";
        message = "backup-manager: backupLocation must be set when enabled";
      }
    ];

    services.borgbackup.jobs."onix-local" = {
      inherit (cfg) exclude;
      paths = finalPaths;
      repo = cfg.backupLocation + "/${config.networking.hostName}";
      encryption.mode = "none";
      compression = "zstd,1";
      startAt = "daily";
      doInit = true;
      prune.keep = {
        daily = 7;
        weekly = 4;
      };
    };

    systemd.services.borgbackup-job-onix-local = {
      unitConfig = {
        ConditionPathIsMountPoint = cfg.backupLocation;
        RequiresMountsFor = cfg.backupLocation;
      };
    };
    environment.etc."backup-manifest.txt".text = ''
      # Backup Manifest for ${config.networking.hostName}
      # Generated:
      ${concatStringsSep "\n" finalPaths}
    '';
  };
}
