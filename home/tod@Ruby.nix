{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation
  ];
  home.packages = with pkgs; [
  ];
  home.stateVersion = "25.11";
}
