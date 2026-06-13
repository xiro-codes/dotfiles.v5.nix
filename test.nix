{ pkgs ? import <nixpkgs> {} }:
let
  eval = pkgs.lib.evalModules {
    modules = [
      (import <home-manager/modules/services/window-managers/hyprland.nix>)
      { wayland.windowManager.hyprland = { enable = true; configType = "lua"; }; }
    ];
  };
in
  eval.config.wayland.windowManager.hyprland.configType
