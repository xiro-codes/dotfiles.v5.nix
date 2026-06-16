{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.local.glances;

in
{
  options.local.glances = {
    enable = mkEnableOption "Glances system monitor";

    port = mkOption {
      type = types.port;
      default = 61208;
      description = "Port for Glances web server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.glances = {
      description = "Glances System Monitor";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${getExe pkgs.glances} -w -p ${toString cfg.port}";
        Restart = "on-failure";
        # Basic hardening
        CapabilityBoundingSet = "";
        PrivateDevices = true;
        ProtectHome = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      };
    };
  };
}
