{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.my-home-module;
in
{
  # 1. Define your home-manager module options here
  options.local.my-home-module = {
    enable = lib.mkEnableOption "my custom home module";

    # Example option:
    # package = lib.mkOption {
    #   type = lib.types.package;
    #   default = pkgs.hello;
    #   description = "Package to install";
    # };
  };

  # 2. Add the actual configuration that gets applied when enabled
  config = lib.mkIf cfg.enable {
    # e.g., home.packages = [ cfg.package ];
  };
}
