{ config, lib, pkgs, ... }:

let
  cfg = config.local.shareManager;
  inherit (lib) mkOption mkIf types;

  # Helper to create SMB mount units
  mkSambaMount = secretName: { shareName, localPath }: {
    what = "//${cfg.serverIp}/${shareName}";
    where = localPath;
    type = "cifs";
    # x-systemd options ensure it doesn't hang boot and only mounts on access
    options = "credentials=${config.sops.secrets."${cfg.secretName}".path},noperm,x-systemd.automount,noauto,x-systemd.idle-timeout=60,uid=1000,gid=100,file_mode=0775,dir_mode=0775,soft";
  };
in
{
  options.local.shareManager = {
    enable = lib.mkEnableOption "Samba mounts from ZimaOS";
    secretName = lib.mkOption {
      type = lib.types.str;
      default = "zima_creds";
    };
    serverIp = mkOption {
      type = types.str;
      default = "192.168.1.100";
    };
    mounts = mkOption {
      type = types.listOf (types.submodule {
        options = {
          shareName = mkOption { type = types.str; description = "Name of the share on ZimaOS"; };
          localPath = mkOption { type = types.str; description = "Local mount point"; };
        };
      });
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    # Required for mounting SMB shares
    environment.systemPackages = [ pkgs.cifs-utils ];

    # Register the mounts with systemd
    systemd.mounts = map (mkSambaMount cfg.secretName) cfg.mounts;

    # Enable the automount logic
    systemd.automounts = map
      (m: {
        where = m.localPath;
        wantedBy = [ "multi-user.target" ];
      })
      cfg.mounts;
  };
}
