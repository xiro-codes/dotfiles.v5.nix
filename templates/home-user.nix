{pkgs, ...}: {
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
  ];
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
