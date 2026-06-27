{
  lib,
  config,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = with self.nixosModules; [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/workstation
    ../profiles/workstation/jovian.nix
    ../profiles/client.nix
  ];

  local = {
    userManager.extraGroups = [
      "input"
      "uinput"
    ];
    bootloader.recoveryUUID = "2b4c50f4-bc58-41ec-bf86-dc0b57a9a130";



    desktops.displayManager = mkForce "std-sddm";
  };

  system.stateVersion = "25.11";

  topology.self.interfaces = {
    enp4s0f3u1u3.network = "home";
    wlan0.network = "home";
    zt0.network = "zerotier";
  };
}
