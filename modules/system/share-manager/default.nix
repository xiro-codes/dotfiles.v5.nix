{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.shareManager;
  inherit (lib) mkOption mkIf types;

  # Helper to create SMB mount units
  mkSambaMount =
    { shareName
    , localPath
    , noShow ? false
    , noAuth ? false
    , options ? [ ]
    ,
    }:
    {
      what = "//${cfg.serverIp}/${shareName}";
      where = localPath;
      type = "cifs";
      # x-systemd options ensure it doesn't hang boot and only mounts on access
      options =
        let
          gvfsFlag = if noShow then "x-gvfs-hide" else "x-gvfs-show";
          authFlag = if noAuth then "guest" else "credentials=${config.sops.secrets."${cfg.secretName}".path}";
          baseOptions = [
            "noperm"
            "x-systemd.automount"
            "noauto"
            "x-systemd.idle-timeout=60"
            "gid=100"
            "file_mode=0775"
            "dir_mode=0775"
            "soft"
            gvfsFlag
            authFlag
          ];
        in
        lib.concatStringsSep "," (baseOptions ++ options);
    };
in
{
  options.local.shareManager = {
    enable = lib.mkEnableOption "Samba mounts from ZimaOS";
    noAuth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Mount shares as guest without credentials";
    };
    secretName = lib.mkOption {
      type = lib.types.str;
      default = "zima_creds";
      description = "Name of sops secret containing SMB credentials";
    };
    serverIp = mkOption {
      type = types.str;
      default = "10.0.0.65";
      description = "IP address of SMB/CIFS server";
    };
    mounts = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            shareName = mkOption {
              type = types.str;
              description = "Name of the share on ZimaOS";
            };
            localPath = mkOption {
              type = types.str;
              description = "Local mount point";
            };
            noShow = mkOption {
              type = types.bool;
              description = "Hide from file manager";
              default = false;
            };
            noAuth = mkOption {
              type = types.bool;
              description = "disable auth";
              default = false;
            };
            options = mkOption {
              type = types.listOf types.str;
              description = "Extra options to add to the defaults";
              default = [ ];
            };
          };
        }
      );
      default = [ ];
      description = "List of SMB/CIFS shares to mount automatically";
    };
  };

  config = mkIf cfg.enable {
    # Required for mounting SMB shares
    environment.systemPackages = [ pkgs.cifs-utils ];
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    services.devmon.enable = true;
    # Register the mounts with systemd
    systemd.mounts = map mkSambaMount cfg.mounts;

    # Enable the automount logic
    systemd.automounts = map
      (m: {
        where = m.localPath;
        wantedBy = [ "multi-user.target" ];
      })
      cfg.mounts;
  };
}
