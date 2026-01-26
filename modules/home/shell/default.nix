{ config, lib, pkgs, ... }:

let
  cfg = config.local.shell;
in
{
  options.local.shell = {
    enable = lib.mkEnableOption "shell module";
  };

  config = lib.mkIf cfg.enable {
    programs.caelestia = {
      enable = true;
      cli.enable = true;
    };
    local.variables.launcher = "caelestia shell drawers toggle launcher";
  };
}
