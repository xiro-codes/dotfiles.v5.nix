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
    nix-cache-client
  ];
  local = {
    nix-cache-client.enable = false;
    registry.enable = true;
    yubikey.enable = true;
  };
}
