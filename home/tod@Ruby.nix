{ pkgs, inputs, ... }:
let
in
{
  imports = [
    ./profiles/workstation
  ];
  home.pointerCursor = {
    gtk.enable = true;
    package = inputs.self.packages.x86_64-linux.fushsia-cursor;
    name = "fuchsia";
    size = 24;
  };
  home.packages = with pkgs; [
    godot
    eog
    prismlauncher
    geminicommit
    crush
    google-chrome
    (symlinkJoin {
      name = "xivlauncher-wrapped";
      paths = [ xivlauncher ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/XIVLauncher.Core --set XL_SECRET_PROVIDER FILE
      '';
    })
  ];
  home.stateVersion = "25.11";
}
