{ pkgs, config, lib, ... }: { 
	imports = [
		./disko.nix
		./hardware-configuration.nix
		../profiles/server.nix
		../profiles/base.nix
		../profiles/limine-uefi.nix
	];
	users.users.tod = {
		shell = pkgs.fish;
		initialPassword = "rockman";
	};
	system.stateVersion = "25.11";
}
