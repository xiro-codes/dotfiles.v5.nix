{ config, lib, pkgs, ... }:

let
  cfg = config.local.zerotier;
in {
  options.local.zerotier = {
    enable = lib.mkEnableOption "zerotier virtual network";
    networkIdSecret = lib.mkOption {
      type = lib.types.str;
      default = "zerotier_network_id";
      description = "The name of the sops secret containing the ZeroTier network ID.";
    };
  };

  config = lib.mkIf cfg.enable {
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
            while ! ${pkgs.zerotierone}/bin/zerotier-cli info >/dev/null 2>&1; do
              sleep 1
            done
            ${pkgs.zerotierone}/bin/zerotier-cli join "$NETWORK_ID"
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
