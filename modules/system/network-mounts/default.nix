{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.network-mounts;
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
  options.local.network-mounts = {
    enable = lib.mkEnableOption "Samba mounts from Onix";
    noAuth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Mount shares as guest without credentials";
    };
    secretName = lib.mkOption {
      type = lib.types.str;
      default = "onix_creds";
      example = "smb_credentials";
      description = "Name of sops secret containing SMB credentials (username=xxx and password=xxx format)";
    };
    serverIp = mkOption {
      type = types.str;
      default = config.local.hosts.onix;
      example = "192.168.1.100";
      description = "IP address or hostname of SMB/CIFS server";
    };
    mounts = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            shareName = mkOption {
              type = types.str;
              example = "Media";
              description = "Name of the share on the SMB server";
            };
            localPath = mkOption {
              type = types.str;
              example = "/media/Media";
              description = "Local mount point path (common locations: /media/, /mnt/, or /run/media/)";
            };
            noShow = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to hide this mount from file manager";
            };
            noAuth = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to mount as guest without authentication";
            };
            options = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [ "ro" "vers=3.0" ];
              description = "Additional mount options to append to defaults";
            };
          };
        }
      );
      default = [ ];
      example = lib.literalExpression ''[
        { shareName = "Media"; localPath = "/media/Media"; }
        { shareName = "Backups"; localPath = "/media/Backups"; noShow = true; }
      ]'';
      description = "List of SMB/CIFS shares to mount automatically with systemd automount";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.noAuth -> (config.sops.secrets ? "${cfg.secretName}");
        message = "network-mounts: Secret '${cfg.secretName}' not found in sops configuration, but authentication is required.";
      }
    ];

    # Required for mounting SMB shares
    environment.systemPackages = [ pkgs.cifs-utils ];
    #services.gvfs.enable = true;
    #services.udisks2.enable = true;
    #services.devmon.enable = true;
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
