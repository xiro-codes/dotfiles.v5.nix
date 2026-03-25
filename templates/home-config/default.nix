{ pkgs
, inputs
, lib
, ...
}:
{
  imports = [ ];
  home.packages = with pkgs; [ ];
  home.stateVersion = "25.11";
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
        user.name = "USERNAME";
        user.email = "EMAIL";
        credential.helper = "store";
        safe.directory = "*";
      };
    };
  };
}
