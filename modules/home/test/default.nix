{config, lib, pkgs, ...}: let 
	cfg = config.local.test 
in {
	options.local.test.enable = lib.mkEnableOption "Enable a simple test module";

	config = lib.mkIf = cfg.enable {
	};
 
}
