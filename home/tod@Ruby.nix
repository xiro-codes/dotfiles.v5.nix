{ pkgs, inputs, lib, ... }: {
  home.stateVersion = "25.11";
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
    platformTheme.name = lib.mkForce "gtk3"; # This set the QT_QPA_PLATFORMTHEME
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
    plex-desktop
  ];
  local = {
    cache = {
      enable = true;
      watch = true;
    };
    theming.enable = true;
    hyprland.enable = true;
    nixvim.enable = true;
    variables.enable = true;
    ranger.enable = true;
    kitty.enable = true;
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
      };
    };
  };
}
