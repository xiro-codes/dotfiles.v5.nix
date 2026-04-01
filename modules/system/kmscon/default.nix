{ config, lib, pkgs, ... }:

let
  cfg = config.local.kmscon;
in {
  options.local.kmscon = {
    enable = lib.mkEnableOption "kmscon terminal emulator for servers";
  };

  config = lib.mkIf cfg.enable {
    services.kmscon = {
      enable = true;
      hwRender = true;
      fonts = [{
        name = "Cascadia Code";
        package = pkgs.cascadia-code;
      }];
    };
  };
}
