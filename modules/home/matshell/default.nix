{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.local.matshell;
in
{
  options.local.matshell = {
    enable = lib.mkEnableOption "MatShell";
  };
  config = lib.mkIf cfg.enable {
    programs.matshell = {
      enable = true;
      autostart = true;
      compositor = "hyprland";
      matugenConfig = true;
    };
  };
}
