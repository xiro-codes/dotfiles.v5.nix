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
	local = {
    hyprland.enable = true;
    hyprpaper = {
      enable = true;
      wallpapers = [
        ./wallpapers/gruvbox.png
      ];
    };
    waybar.enable = true;
    hyprlauncher.enable = true;
    nixvim.enable = true;
    variables.enable = true;
    ranger.enable = true;
    kitty.enable = true;
    fonts.enable = true;
  };

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
