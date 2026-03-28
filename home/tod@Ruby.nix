{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
    crush
    surge-XT
    vital
  ];
  home.stateVersion = "25.11";
}
