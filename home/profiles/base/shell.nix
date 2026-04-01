{ ... }:
{
  local = {
    secrets.enable = true;
    ssh.enable = true;
    fish.enable = true;
    starship.enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };
}
