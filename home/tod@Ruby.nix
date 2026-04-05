{ pkgs, inputs, ... }:
let
  unstable-pkgs = import inputs.nixpkgs-unstable {
    system = pkgs.system;
  };
in
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
    eog
    #unstable-pkgs.zed-editor
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
