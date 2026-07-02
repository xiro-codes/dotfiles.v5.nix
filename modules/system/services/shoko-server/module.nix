{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    getExe
    ;

  cfg = config.local.shoko-server;
in
{
  options.local.shoko-server = {
    enable = mkEnableOption "Shoko Server native service";

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/shoko";
      description = "Directory to store Shoko Server configuration and data.";
    };
  };

  config = mkIf cfg.enable {
    users.users.shoko = {
      isSystemUser = true;
      group = "shoko";
      extraGroups = [ "media" ]; # allow reading media files
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.shoko = { };
    # Create media group if it doesn't exist, though typically it's created by the media stack
    users.groups.media = { };

    systemd.services.shoko-server = {
      description = "Shoko Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "shoko";
        Group = "shoko";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${getExe pkgs.shoko-server}";
        Restart = "on-failure";

        # Hardening
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectControlGroups = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        RestrictAddressFamilies = [
          "AF_INET6"
        ];
        ReadWritePaths = [ cfg.dataDir ];
      };
    };
  };
}
