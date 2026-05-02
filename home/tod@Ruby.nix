{
  pkgs,
  inputs,
  ...
}:
let
in
{
  imports = [
    ./profiles/workstation
  ];
  local.helix.enable = true;
  local.kakoune.enable = true;
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
  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    matches.base.matches = [ ];
  };
  home.stateVersion = "25.11";
}
