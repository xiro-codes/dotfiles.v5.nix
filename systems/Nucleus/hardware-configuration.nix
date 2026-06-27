{ lib, ... }:
{
  # Hardware configuration for the Seed ISO is minimal.
  # Handled by installation-cd-minimal.nix
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
