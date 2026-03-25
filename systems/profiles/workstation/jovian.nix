{ config, pkgs, lib, inputs, ... }: {
  imports = [
    inputs.jovian.nixosModules.jovian
  ];
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "tod";
      desktopSession = "hyprland";
    };
    devices.steamdeck.enable = false;
    hardware.has.amd.gpu = true;
  };
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
    "steam-jupiter-unwrapped"
    "steamdeck-hw-theme"
  ];
}
