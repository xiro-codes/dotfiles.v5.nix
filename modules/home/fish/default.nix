{config, lib, pkgs, osConfig ? {}, ... }:
let 
	isDefaultShell = (osConfig.users.users.${config.home.username}.shell or null) == pkgs.fish;
in {
	options.local.fish = {
		enable = lib.mkOption {
			type = lib.types.bool;
			default = isDefaultShell;
			description = "Enable fish config if it is the system shell.";
		};
	};
	config = lib.mkIf config.local.fish.enable {
		programs.fish = {
			enable = true;
			interactiveShellInit = "set -g fish_greeting ''";
		};
	};
}
