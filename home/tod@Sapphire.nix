{ pkgs, lib, ... }: {
  home.stateVersion = "25.11";
  nix.settings.substituters = [

    "http://10.0.0.65:8080/main?priority=1"
  ];
  nix.settings.trusted-public-keys = [
    "main:CqlQUu3twINKw6rrCtizlAYkrPOKUicoxMyN6EvYnbk="
  ];
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
    theming.enable = true;
    mako.enable = true;
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
