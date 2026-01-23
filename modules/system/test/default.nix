{ config, lib, ...}:{
	options.local.test.enable = lib.mkEnableOption "Enable a simple test module";
	config = lib.mkIf config.local.test.enable {
		
	};
}
