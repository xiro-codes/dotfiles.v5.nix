{pkgs, lib, ... }: {
	home.stateVersion = "25.11";
	home.packages = with pkgs; [
		unzip
		p7zip
		sysstat
		grim
		slurp
		bottom
		duf
		dust
	];
	local.nixvim.enable = true;
	programs = {
		home-manager.enable = true;
		direnv = {
			enable = true;
			nix-direnv.enable = true;
		};
		git = {
			enable = true;
			settings = {
				user.name = "Travis Davis";
				user.email = "me@tdavis.dev";
				credential.helper = "store";
				safe.directory = "*";
			};
		};
	};
}
