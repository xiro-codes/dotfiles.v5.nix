{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.ddns-updater;
in
{
  options.services.ddns-updater = {
    config = mkOption {
      type = types.attrs;
      default = { };
      description = "The configuration for ddns-updater.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ddns-updater = {
      serviceConfig.ExecStartPre = [
        (
          "+"
          + "${
            inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.setup-ddns-config
          }/bin/setup-ddns-config ${config.sops.secrets."apps/cloudflare_token".path} ${
            config.sops.secrets."apps/cloudflare_zone_id".path
          } ${pkgs.writeText "ddns-config.json" (builtins.toJSON cfg.config)}"
        )
      ];
    };
    services.ddns-updater.environment.CONFIG_FILEPATH = "/etc/ddns-updater/config.json";
  };
}
