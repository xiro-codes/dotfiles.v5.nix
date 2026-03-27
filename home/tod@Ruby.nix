{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
    crush
  ];
  home.stateVersion = "25.11";
}
