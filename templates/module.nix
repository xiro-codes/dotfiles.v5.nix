{ config, lib, pkgs, ... }:

let
  cfg = config.myNamespace.TEMPLATE_NAME;
in {
  options.myNamespace.TEMPLATE_NAME = {
    enable = lib.mkEnableOption "TEMPLATE_NAME module";
  };

  config = lib.mkIf cfg.enable {
    # Add your module configuration here
  };
}
