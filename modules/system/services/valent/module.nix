{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.valent;
in
{
  options.local.valent = {
    enable = mkEnableOption "Valent (KDE Connect protocol) system integration";
  };

  config = mkIf cfg.enable {
    # Open ports for KDE Connect protocol
    # TCP/UDP 1714-1764
    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };
}
