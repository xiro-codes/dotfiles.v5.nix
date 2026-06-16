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
  ];
  home.packages = with pkgs; [
    godot
    eog
    prismlauncher
    geminicommit
    crush
    antigravity-fhs
    z-library-desktop
    (symlinkJoin {
      name = "xivlauncher-wrapped";
      paths = [ xivlauncher ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/XIVLauncher.Core --set XL_SECRET_PROVIDER FILE
      '';
    })
  ];
  local.wallpapers = {
    name = "13054947.png";
  };
  dconf.settings = {
    "org/nemo/desktop" = {
      desktop-icons = true;
    };
  };
  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    matches.base.matches = [
      {
        trigger = "dto";
        replace = "dot";
        word = true;
      }
    ];
  };
  home.stateVersion = "25.11";
}
