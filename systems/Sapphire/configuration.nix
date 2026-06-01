{
  lib,
  config,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) mkForce mkAfter;
in
{
  imports = with self.nixosModules; [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/client.nix
    ../profiles/workstation
    ../profiles/workstation/jovian.nix
    ../profiles/server
  ];

  # Sapphire-specific configuration
  local = {
    bootloader.recoveryUUID = "0d9dddd8-9511-4101-9177-0a80cfbeb047";

    backup-manager.paths = mkAfter [
      "/etc/nixos/"
    ];
  };

  system.stateVersion = "25.11";

  topology.self.interfaces = {
    eth0.network = "home";
    zt0.network = "zerotier";
  };
}
