{ self, ... }:
{
  imports = [
    ./networking.nix
    ./media.nix
    ./services.nix
    ./sharing.nix

    self.nixosModules."networking/reverse-proxy"
    self.nixosModules."services/dashboard"
    self.nixosModules."services/gitea"
    self.nixosModules."services/media"
    self.nixosModules."services/gog-downloader"
    self.nixosModules."services/downloads"
    self.nixosModules."services/file-browser"
    self.nixosModules."infra/harmonia-cache"
    self.nixosModules."services/minecraft-server"
    self.nixosModules."infra/recovery-builder"
    self.nixosModules."services/file-sharing"
    self.nixosModules."virtualization/containers"
    self.nixosModules."virtualization/incus"
    self.nixosModules."services/metrics"
    self.nixosModules."services/nixarr-stack"
  ];

  local.metrics.enable = false;
}
