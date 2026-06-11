{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.my-module;
  inherit (lib) mkEnableOption mkOption types mkIf;
in
{
  # 1. Define your module options here
  options.local.my-module = {
    enable = mkEnableOption "my custom system module";

    # Example string option:
    # mySetting = mkOption {
    #   type = types.str;
    #   default = "value";
    #   description = "An example setting";
    # };
  };

  # 2. Add the actual configuration that gets applied when enabled
  config = mkIf cfg.enable {
    # e.g., environment.systemPackages = [ pkgs.hello ];
  };
}
