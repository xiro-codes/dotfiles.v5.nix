{
  config,
  lib,
  inputs,
  inputs-nix,
  ...
}:
let
  inherit (lib)
    attrValues
    concatMap
    filterAttrs
    hasPrefix
    mkEnableOption
    mkIf
    mkOption
    types
    unique
    ;

  cfg = config.local.impermanence;

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

  finalDirectories = unique (autoUserPaths ++ cfg.directories);
in
{
  imports = [
  ];

  options.local.impermanence = {
    enable = mkEnableOption "Enable impermanence (persistence)";
    persistentStoragePath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Path to the persistent storage";
    };
    directories = mkOption {
      type = types.listOf (types.either types.str types.attrs);
      default = [ ];
      description = "Directories to persist";
    };
    files = mkOption {
      type = types.listOf (types.either types.str types.attrs);
      default = [ ];
      description = "Files to persist";
    };
  };

  config = mkIf cfg.enable {
    environment.persistence."${cfg.persistentStoragePath}" = {
      hideMounts = true;
      directories = finalDirectories;
      files = cfg.files;
    };
  };
}
