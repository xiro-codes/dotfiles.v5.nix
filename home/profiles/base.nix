# Base home profile - Common configuration for all users
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  local = {
    secrets.enable = true;
    ssh.enable = true;
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
    # Archive tools
    unzip
    p7zip

    # System monitoring
    sysstat
    bottom
    duf
    dust
    procs

    # CLI utilities
    bat
    ripgrep
    fd
    tealdeer
    gping
  ];
}
