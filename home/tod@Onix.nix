{ pkgs, ... }:
{
  imports = [
    #./profiles/workstation.nix

  ];
  local = {
    fish.enable = true;
    nixvim.enable = true;
    ranger.enable = true;
    fonts.enable = false;
    stylix.enable = false;
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
  home.packages = with pkgs; [
    unzip
    p7zip
    sysstat
    bottom
    duf
    dust
    cascadia-code
    libnotify
    bat
    ripgrep
    fd
    procs
    tealdeer
    gping
  ];
  home.stateVersion = "25.11";
}
