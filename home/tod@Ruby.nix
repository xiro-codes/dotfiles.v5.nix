{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
    crush
    eog
    xivlauncher
  ];
  services.gnome-keyring.enable = true;
  home.stateVersion = "25.11";
}
