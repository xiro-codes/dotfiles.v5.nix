{ pkgs, inputs, ... }:
let
  unstable-pkgs = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.permittedInsecurePackages = [ "openclaw-2026.3.12" ];
  };
in
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
    eog
    crush
    unstable-pkgs.openclaw
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
