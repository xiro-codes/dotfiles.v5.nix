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
    gog-downloader
    downloads
    file-browser
    harmonia-cache
    minecraft-server
    recovery-builder
    file-sharing
    containers
    incus
    metrics
    pihole
    nixarr-stack
  ];

  local.metrics.enable = false;
}
