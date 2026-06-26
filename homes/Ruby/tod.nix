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
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs

    ];
  };
  home.packages = with pkgs; [
    godot
    eog
    prismlauncher
    geminicommit
    antigravity-fhs
    vlc

    #(symlinkJoin {
    #  name = "xivlauncher-wrapped";
    #  paths = [ xivlauncher ];
    #  buildInputs = [ makeWrapper ];
    #  postBuild = ''
    #    wrapProgram $out/bin/XIVLauncher.Core --set XL_SECRET_PROVIDER FILE
    #  '';
    #})
  ];
  local.wallpapers = {
    name = "AG1.png";
  };
  local.valent.enable = true;
  local.kdeconnect.enable = lib.mkForce false;
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
