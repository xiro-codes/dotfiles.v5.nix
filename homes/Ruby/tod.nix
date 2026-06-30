{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  getSystem = p: p.stdenv.hostPlatform.system;
in
{
  imports = [
    ../profiles/workstation
  ];
  home.packages = with pkgs; [
    eog
    geminicommit
    antigravity-fhs
    vlc
    inputs.tagstudio.packages.${getSystem pkgs}.tagstudio
    #(symlinkJoin {
    #  name = "xivlauncher-wrapped";
    #  paths = [ xivlauncher ];
    #  buildInputs = [ makeWrapper ];
    #  postBuild = ''
    #    wrapProgram $out/bin/XIVLauncher.Core --set XL_SECRET_PROVIDER FILE
    #  '';
    #})
  ];
  # local.wallpapers = {
  #   name = "AG1.png";
  # };
  # TODO make this more useful the auto complete function is good at catching minor typos but i wish it could learn or i could log my typos 
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
