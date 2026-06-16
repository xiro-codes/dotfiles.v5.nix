{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.coolercontrol;
in
{
  options.local.coolercontrol = {
    enable = mkEnableOption "CoolerControl daemon and web UI";
    port = mkOption {
      type = types.port;
      default = 11987;
      readOnly = true;
      description = "Port for the CoolerControl web UI.";
    };
  };

  config = mkIf cfg.enable {
    programs.coolercontrol = {
      enable = true;
    };
  };
}
