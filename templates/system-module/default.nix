{ config, lib, pkgs, ... }:
let cfg = config.local.TEMPLATE_NAME;
in {
  options.local.TEMPLATE_NAME = {
    enable = lib.mkEnableOption "TEMPLATE_NAME module";
  };
  config = lib.mkIf cfg.enable { };
}
