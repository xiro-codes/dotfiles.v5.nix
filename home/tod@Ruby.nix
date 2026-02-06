{ pkgs, ... }:
{
  imports = [
    ./profiles/workstation.nix
  ];
  home.packages = with pkgs; [
    curl
    wget
    dig
    nmap
    iperf3
  ];
  home.stateVersion = "25.11";
}
