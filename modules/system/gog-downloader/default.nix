{ config, pkgs, lib, ... }:
let
  cfg = config.local.gog-downloader;
  gogCmd = "${pkgs.lgogdownloader}/bin/lgogdownloader";
in
{
  options.local.gog-downloader = {
    enable = lib.mkEnableOption "Automated GOG library synchronization";
    directory = lib.mkOption {
      type = lib.types.path;
      default = "/media/Media/games";
      description = "Directory where games will be downloaded";
    };
    interval = lib.mkOption {
      type = lib.types.path;
      default = "daily";
      description = "Systemd timer interval.";
    };
    platforms = lib.mkOption {
      type = lib.types.str;
      default = "l+w";
      description = "Platforms to download (l=linux, w=windows, m=mac)";
    };
    extraArgs = lib.mkOption {
      type = lib.types.str;
      default = "--repair --download --check-patches";
      description = "Extra arguments passed to lgogdownloader";
    };
    secretFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to a file containing environment variables for GOG login.
        Expected format:
        GOG_EMAIL=user@example.com
        GOG_PASSWORD=yourpassword
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.lgogdownloader ];
    systemd.timers.gog-downloader = {
      description = "Timer for GOG Library Sync";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
    systemd.services.gog-downloader = {
      description = "GOG Library Sync Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "root"; # Or your specific gaming user
        EnvironmentFile = cfg.secretFile;
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.directory}";
        ExecStart = pkgs.writeShellScript "gog-sync-script" ''
          # Perform the download/sync
          ${gogCmd} \
            --directory ${cfg.directory} \
            --platform ${cfg.platforms} \
            ${cfg.extraArgs}
        '';
      };
    };

  };
}
