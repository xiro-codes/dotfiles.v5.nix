{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
    eog
    crush
    aider-chat-full
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
