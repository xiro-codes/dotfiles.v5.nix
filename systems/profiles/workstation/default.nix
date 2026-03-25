{ ... }:
{
  imports = [
    ./hardware.nix
    ./desktop.nix
    ./software.nix
  ];
  local.nix-cache-client.enable = true;
}
