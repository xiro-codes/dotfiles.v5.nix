{ pkgs, inputs, ... }: {
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
