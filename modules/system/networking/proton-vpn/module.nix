{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.local.protonvpn;
in
{
  options = {
    local.protonvpn = {
      enable = mkEnableOption "Enable ProtonVPN (using Wireguard).";

      autostart = mkOption {
        default = true;
        example = "true";
        type = types.bool;
        description = "Automatically set up ProtonVPN when NixOS boots.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.wg-quick.interfaces."wg0" = {
      autostart = cfg.autostart;
      configFile = config.sops.secrets."protonvpn_wg_conf".path;
    };
    local.secrets.keys = [ "protonvpn_wg_conf" ];
  };
}
