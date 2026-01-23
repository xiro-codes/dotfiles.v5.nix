{pkgs, lib, ... }: {
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
	programs = {
		home-manager.enable = true;
		direnv = {
			enable = true;
			nix-direnv.enable = true;
		};
		git = {
			enable = true;
			userName = "Travis Davis";
			userEmail = "me@tdavis.dev";
			extraConfig = {
				credential.helper = "store";
				safe.directory = "*";

			};
		};
	};
}
