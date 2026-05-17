{
  config,
  pkgs,
  lib,
  inputs,
  inputs-nix,
  ...
}:
{
  imports = [
    inputs-nix.inputs.jovian.nixosModules.jovian
  ];
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "tod";
      desktopSession = "hyprland";
    };
    devices.steamdeck.enable = lib.mkDefault true;
    hardware.has.amd.gpu = true;
  };

  # Handle unfree packages for Steam
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "steam-jupiter-unwrapped"
      "steamdeck-hw-theme"
    ];
}
