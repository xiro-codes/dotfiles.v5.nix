{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.impermanence;
in
{
  options.local.impermanence = {
    enable = mkEnableOption "Enable home impermanence (persistence)";
    persistentStoragePath = mkOption {
      type = types.str;
      default = "/persist${config.home.homeDirectory}";
      description = "Path to the persistent storage for user";
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
    allowOther = mkOption {
      type = types.bool;
      default = true;
      description = "Allow other users to access the mount";
    };
  };

  config = mkIf cfg.enable {
    home.persistence."${cfg.persistentStoragePath}" = {
      allowOther = cfg.allowOther;
      directories = cfg.directories;
      files = cfg.files;
    };
  };
}
