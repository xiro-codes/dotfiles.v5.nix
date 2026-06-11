{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.my-home-module;
  inherit (lib) mkEnableOption mkOption types mkIf;
in
{
  # 1. Define your home-manager module options here
  options.local.my-home-module = {
    enable = mkEnableOption "my custom home module";

    # Example option:
    # package = mkOption {
    #   type = types.package;
    #   default = pkgs.hello;
    #   description = "Package to install";
    # };
  };

  # 2. Add the actual configuration that gets applied when enabled
  config = mkIf cfg.enable {
    # e.g., home.packages = [ cfg.package ];
  };
}
