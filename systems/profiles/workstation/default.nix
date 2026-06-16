{ self, ... }:
{
  imports = with self.nixosModules; [
    ./hardware.nix
    ./desktop.nix
    ./software.nix
    
    registry
    yubikey
    bluetooth
    pipewire-audio
    gaming
    flatpak
    desktops
    harmonia-client
  ];
  local = {
    harmonia-client.enable = false;
    registry.enable = true;
    yubikey.enable = true;
  };
}
