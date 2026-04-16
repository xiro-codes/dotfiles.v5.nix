{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ddns-updater;
in {
  options.services.ddns-updater = {
    config = mkOption {
      type = types.attrs;
      default = {};
      description = "The configuration for ddns-updater.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ddns-updater = {
      serviceConfig.ExecStartPre = [
        ("+" + pkgs.writeShellScript "setup-ddns-config" ''
          mkdir -p /etc/ddns-updater
          TOKEN=$(cat ${config.sops.secrets."apps/cloudflare_token".path})
          ZONE=$(cat ${config.sops.secrets."apps/cloudflare_zone_id".path})
          ${pkgs.jq}/bin/jq --arg token "$TOKEN" --arg zone "$ZONE" \
            '.settings[0].token = $token | .settings[0].zone_identifier = $zone' \
            <<'EOF' > /etc/ddns-updater/config.json
          ${builtins.toJSON cfg.config}
          EOF
          chmod 600 /etc/ddns-updater/config.json
        '')
      ];
    };
    services.ddns-updater.environment.CONFIG_FILEPATH = "/etc/ddns-updater/config.json";
  };
}
