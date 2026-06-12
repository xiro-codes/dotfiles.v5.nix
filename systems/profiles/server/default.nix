{ self, ... }:
{
  imports = with self.nixosModules; [
    ./networking.nix
    ./media.nix
    ./services.nix
    ./sharing.nix
  ];

  local.metrics.enable = false;
}
