{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ../profiles/workstation
  ];

  local = {
    caelestia-shell.enable = mkForce false;
    hyprland.enable = mkForce false;
    mpd.enable = mkForce false;
  };

  home.packages = with pkgs; [
    (symlinkJoin {
      name = "xivlauncher-wrapped";
      paths = [ xivlauncher ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/XIVLauncher.Core --set XL_SECRET_PROVIDER FILE
      '';
    })
  ];
  # local.wallpapers = {
  #   name = "miku.jpeg";
  # };
  home.stateVersion = "25.11";
}
