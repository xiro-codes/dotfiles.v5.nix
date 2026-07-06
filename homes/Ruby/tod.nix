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
    termius
    inkscape
    godot
    crush
    #(symlinkJoin {
    #  name = "xivlauncher-wrapped";
    #  paths = [ xivlauncher ];
    #  buildInputs = [ makeWrapper ];
    #  postBuild = ''
    #    wrapProgram $out/bin/XIVLauncher.Core --set XL_SECRET_PROVIDER FILE
    #  '';
    #})
  ];
  programs.zen-browser = {
    enable = true;
    profiles.default = {
    };
  };

  xdg.desktopEntries."zen-beta" = {
    name = "Zen Browser (Beta)";
    genericName = "Web Browser";
    exec = "hypr-summon zen-beta zen-beta --name zen-beta %U";
    icon = "zen-browser";
    terminal = false;
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    type = "Application";
  };
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
