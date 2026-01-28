{ pkgs, lib, ... }: {
  local = {
    cache = {
      enable = true;
      watch = true;
    };
    fish.enable = true;
    hyprland.enable = true;
    kitty.enable = true;
    nixvim.enable = true;
    theming.enable = true;
    ranger.enable = true;
    fonts.enable = true;
    mpd.enable = true;
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
        core.sshCommand = "ssh -i $HOME/.ssh/github";
      };
    };
  };

  gtk = {
    enable = lib.mkForce true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = lib.mkForce true;
    style.name = lib.mkForce "adwaita-dark";
    platformTheme.name = lib.mkForce "gtk3";
  };

  home.packages = with pkgs; [
    unzip
    p7zip
    sysstat
    grim
    slurp
    bottom
    duf
    dust
    cascadia-code
    libnotify
    firefox
    discord
  ];
}
