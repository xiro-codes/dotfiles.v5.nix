{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
    godot
    via
  ];
  home.stateVersion = "25.11";
}
