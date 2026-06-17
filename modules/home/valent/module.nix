{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf getExe;
  cfg = config.local.valent;
in
{
  options.local.valent = {
    enable = mkEnableOption "Valent user configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.valent ];

    systemd.user.services.valent = {
      Unit = {
        Description = "Valent (KDE Connect implementation)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${getExe pkgs.valent} --gapplication-service";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
