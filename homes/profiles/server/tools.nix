{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Server monitoring
    htop
    iotop
    ncdu

    # Network tools
    curl
    wget
    dig
    nmap
    iperf3

    # System administration
    tmux
    screen
  ];
}
