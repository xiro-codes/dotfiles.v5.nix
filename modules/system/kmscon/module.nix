{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.kmscon;
in
{
  options.local.kmscon = {
    enable = mkEnableOption "kmscon terminal emulator for servers";
  };

  config = mkIf cfg.enable {
    services.kmscon = {
      enable = true;
      hwRender = true;
      fonts = [
        {
          name = "Cascadia Code";
          package = pkgs.cascadia-code;
        }
      ];
    };
  };
}
