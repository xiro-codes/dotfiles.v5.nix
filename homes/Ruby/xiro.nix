{
  pkgs,
  lib,
  inputs,
  ...
}:
let
in
{
  imports = [
    ../profiles/workstation
    # ../profiles/nsfw
  ];
  home.packages = with pkgs; [
    vlc
  ];
  services.espanso = {
    package = pkgs.espanso-wayland;
    matches.base.matches = [
      {
        trigger = "dto";
        replace = "dot";
        word = true;
      }
    ];
  };
  home.stateVersion = "26.05";
}

