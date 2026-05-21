{ self, ... }:
{
  imports = with self.nixosModules; [
    ./networking.nix
    ./media.nix
    ./services.nix
    ./sharing.nix
    
    reverse-proxy
    dashboard
    gitea
    media
    downloads
    file-browser
    harmonia-cache
    minecraft-server
    recovery-builder
    file-sharing
    containers
    incus
    metrics
  ];

  local.metrics.enable = true;
}
