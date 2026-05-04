{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.my-module;
in
{
  # 1. Define your module options here
  options.local.my-module = {
    enable = lib.mkEnableOption "my custom system module";

    # Example string option:
    # mySetting = lib.mkOption {
    #   type = lib.types.str;
    #   default = "value";
    #   description = "An example setting";
    # };
  };

  # 2. Add the actual configuration that gets applied when enabled
  config = lib.mkIf cfg.enable {
    # e.g., environment.systemPackages = [ pkgs.hello ];
  };
}
