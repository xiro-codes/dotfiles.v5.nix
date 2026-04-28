{ config, lib, ... }:

let
  cfg = config.local.yazi;
in
{
  options.local.yazi = {
    enable = lib.mkEnableOption "enable yazi";
  };

  config = lib.mkIf cfg.enable {
    local.variables.fileManager = "yazi";
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "yy";
    };
  };
}
