{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
  ];
  home.stateVersion = "25.11";
}
