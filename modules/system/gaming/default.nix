{ config, lib, pkgs, ... }:

let
  cfg = config.local.gaming;
in {
  options.local.gaming = {
    enable = lib.mkEnableOption "Gaming optimizations";
  };

  config = lib.mkIf cfg.enable {
    # Enable Steam
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # Optimize Bluetooth for controllers (lower latency)
    # This adjusts the polling intervals in the kernel
    boot.kernel.sysctl = {
      "net.core.netdev_max_backlog" = 5000;
    };

    # Gamemode allows games to request temporary system optimizations
    programs.gamemode.enable = true;

    # Support for Xbox and DualSense controllers
    hardware.xpadneo.enable = true; # Xbox One wireless
    services.joycond.enable = true; # Nintendo Joy-Cons
    
    # Enable udev rules for various controllers (DualSense, Steam Controller, etc)
    hardware.steam-hardware.enable = true;
  };
}
