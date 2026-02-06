{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation.nix
  ];
  home.packages = with pkgs; [
  ];
  home.stateVersion = "25.11";
}
