# Server home profile - Headless server configuration
{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  local = {
    nixvim.enable = true;
    ranger.enable = true;
    
    # No GUI features
    fonts.enable = false;
    stylix.enable = false;
    hyprland.enable = false;
    kitty.enable = false;
    mpd.enable = false;
    caelestia.enable = false;
  };

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
