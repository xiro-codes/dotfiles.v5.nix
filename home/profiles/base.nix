# Base home profile - Common configuration for all users
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  local = {
    secrets.enable = true;
    ssh.enable = true;
    cache = {
      enable = true;
      watch = true;
    };
    fish.enable = true;
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
    #dogdns
  ];
}
