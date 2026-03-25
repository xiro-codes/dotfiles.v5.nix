{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Travis Davis";
      user.email = "me@tdavis.dev";
      credential.helper = "store";
      safe.directory = "*";
      core.sshCommand = "ssh -i $HOME/.ssh/github";
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
