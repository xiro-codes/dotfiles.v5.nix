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

  nixpkgs.overlays = [
    (final: prev: {
      gamescope = prev.gamescope.overrideAttrs (old: {
        patches = builtins.filter (p: ! (builtins.isString p && builtins.match ".*shaders-path\\.patch" p != null) && ! (builtins.isPath p && builtins.match ".*shaders-path\\.patch" (builtins.toString p) != null)) (old.patches or []);
      });
    })
  ];

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
