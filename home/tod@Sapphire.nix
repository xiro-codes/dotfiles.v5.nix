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
    waybar.enable = true;
    hyprlauncher.enable = true;
    nixvim.enable = true;
    variables.enable = true;
    ranger.enable = true;
    kitty.enable = true;
    fonts.enable = true;
    mpd.enable = true;
  };
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 16;
    };
    iconTheme = {
      package = pkgs.gruvbox-dark-icons-gtk;
      name = "oomox-gruvbox-dark";
    };
  };
	programs = {
		home-manager.enable = true;
		direnv = {
			enable = true;
			nix-direnv.enable = true;
      silent = true;
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
