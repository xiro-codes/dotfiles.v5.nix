{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.yazi;
in
{
  options.local.yazi = {
    enable = mkEnableOption "enable yazi";
  };

  config = mkIf cfg.enable {
    local.variables.fileManager = "yazi";
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "yy";
    };
  };
}
