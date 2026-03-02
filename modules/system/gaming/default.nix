{ config, lib, pkgs, ... }:

let
  cfg = config.local.gaming;
  packager = import ./packager.nix { inherit pkgs lib; };
  myGames =
    if cfg.packageGames && cfg.gogPath != null
    then packager.scanAndPackage cfg.gogPath
    else { };
  debugGames = builtins.trace "Detected Games: ${lib.concatStringsSep ", " (builtins.attrNames myGames)}" myGames;
in
{
  options.local.gaming = {
    enable = lib.mkEnableOption "Gaming optimizations";
    packageGames = lib.mkEnableOption "automatic GOG game packaging";
    gogPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the mounted GOG installers directory";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (lib.attrValues debugGames) ++ [
      #pkgs.wineWow64Packages.stable
      #pkgs.innoextract
    ];
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
    services.udev.extraRules = ''
      # PS5 DualSense wired (USB)
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666"
      # PS5 DualSense Bluetooth
      KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0666"
    '';
  };
}
