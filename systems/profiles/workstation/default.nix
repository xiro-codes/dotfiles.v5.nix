{ self, ... }:
{
  imports = with self.nixosModules; [
    ./hardware.nix
    ./desktop.nix
    ./software.nix
    
    self.nixosModules."infra/registry"
    self.nixosModules."desktop/yubikey"
    self.nixosModules."networking/bluetooth"
    self.nixosModules."desktop/pipewire-audio"
    self.nixosModules."desktop/gaming"
    self.nixosModules."desktop/flatpak"
    self.nixosModules."desktop/desktops"
    self.nixosModules."infra/harmonia-client"
  ];
  local = {
    harmonia-client.enable = false;
    registry.enable = true;
    yubikey.enable = true;
  };
}
