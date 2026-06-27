{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    getExe'
    ;
  cfg = config.local.zerotier;
in
{
  options.local.zerotier = {
    enable = mkEnableOption "zerotier virtual network";
    networkIdSecret = mkOption {
      type = types.str;
      default = "zerotier_network_id";
      description = "The name of the sops secret containing the ZeroTier network ID.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.local.secrets.enable;
        message = "zerotier requires local.secrets to be enabled";
      }
    ];
    local.secrets.keys = [ cfg.networkIdSecret ];
    services.zerotierone.enable = true;

    systemd.services.zerotier-join = {
      description = "Join ZeroTier Network from Secret";
      after = [ "zerotierone.service" ];
      wants = [ "zerotierone.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if [ -f ${config.sops.secrets."${cfg.networkIdSecret}".path} ]; then
          NETWORK_ID=$(cat ${config.sops.secrets."${cfg.networkIdSecret}".path})
          if [ -n "$NETWORK_ID" ]; then
            while ! ${getExe' pkgs.zerotierone "zerotier-cli"} info >/dev/null 2>&1; do
              sleep 1
            done
            ${getExe' pkgs.zerotierone "zerotier-cli"} join "$NETWORK_ID"
          else
            echo "Network ID is empty!"
            exit 1
          fi
        else
          echo "Secret file not found!"
          exit 1
        fi
      '';
    };
  };
}
