{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.local.persistence;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.local.persistence = {
    enable = mkEnableOption "Enable impermanence (persistence)";
    persistentStoragePath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Path to the persistent storage";
    };
    directories = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Directories to persist";
    };
    files = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Files to persist";
    };
  };

  config = mkIf cfg.enable {
    environment.persistence."${cfg.persistentStoragePath}" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ] ++ cfg.directories;
      files = [
        "/etc/machine-id"
      ] ++ cfg.files;
    };
  };
}
