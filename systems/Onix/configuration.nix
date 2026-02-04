{ pkgs, config, lib, ... }: { 
	imports = [
		./disko.nix
		./hardware-configuration.nix
		../profiles/limine-uefi.nix
	];
	users.users.tod = {
		shell = pkgs.fish;
		initialPassword = "rockman";
	};
	system.stateVersion = "25.11";
}
