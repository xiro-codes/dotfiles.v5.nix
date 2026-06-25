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
  # TODO: ARCHITECTURE SMELL: Hardcoded user subfolders.
  # If a user relies on non-standard directories (e.g., 'Development' instead of 'Projects'), they miss out on backups.
  # Consider deriving this dynamically from `config.home-manager.users.${name}.xdg.userDirs` or a dedicated Home Manager option.
  userSubFolders = [
    "Projects"
    "Documents"
    "Pictures"
    "Videos"
    ".ssh"
  ];
  realUsers = filterAttrs (
    name: user:
    user.isNormalUser
    && user.home != null
    && (hasPrefix "/home/" user.home)
    && (
      !builtins.hasAttr name config.home-manager.users
      || config.home-manager.users.${name}.local.backup
    )
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

    services.borgbackup.jobs."${config.networking.hostName}-local" = {
      inherit (cfg) exclude;
      paths = finalPaths;
      repo = cfg.backupLocation + "/${config.networking.hostName}";
      # TODO: SECURITY SMELL: Backup encryption is currently disabled.
      # This is highly unsafe for system backups. It should be replaced with `encryption.mode = "repokey"`
      # and an `encryption.passCommand` fetching a secret managed by `sops-nix`.
      encryption.mode = "none";
      compression = "zstd,1";
      startAt = "daily";
      doInit = true;
      prune.keep = {
        daily = 7;
        weekly = 4;
      };
    };

    systemd.services."borgbackup-job-${config.networking.hostName}-local" = {
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
