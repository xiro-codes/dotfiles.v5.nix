{ self, ... }:
{
  imports = with self.nixosModules; [
    ./hardware.nix
    ./desktop.nix
    ./software.nix
    
    registry
    yubikey
  ];
  local = {
    nix-cache-client.enable = true;
    registry.enable = true;
    yubikey.enable = true;
  };
}
