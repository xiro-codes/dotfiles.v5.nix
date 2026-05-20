{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/client.nix
    ../profiles/workstation
    ../profiles/workstation/jovian.nix
  ];

  # Sapphire-specific configuration
  local = {
    bootloader.recoveryUUID = "0d9dddd8-9511-4101-9177-0a80cfbeb047";

    backup-manager.paths = lib.mkAfter [
      "/etc/nixos/"
    ];
    zerotier.enable = true;
    gaming.enable = true;
    desktops.enable = true;
    desktops.hyprland = mkForce false;
    desktops.displayManager = "none";
    desktops.plasma6 = true;
  };

  users.users.build = {
    isNormalUser = true;
    description = "Nix remote build user";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7231Oawo+cIcWU22G0qfWh5N77r0neXl0ZSTWLQz+f build@installer-iso"
    ];
  };

  nix.settings.trusted-users = [ "build" ];

  system.stateVersion = "25.11";
}
