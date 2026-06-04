{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkForce mkDefault getName;
in
{
  imports = [
    inputs.jovian.nixosModules.jovian
  ];

  local.desktops = {
    hyprland = mkForce false;
    displayManager = "none";
    plasma6 = true;
  };

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "tod";
      desktopSession = "plasma";
    };
    devices.steamdeck.enable = mkDefault true;
    hardware.has.amd.gpu = true;
  };

  # Handle unfree packages for Steam
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "steam-jupiter-unwrapped"
      "steamdeck-hw-theme"
    ];
}
