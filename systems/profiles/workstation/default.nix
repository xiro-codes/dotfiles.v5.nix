{ ... }:
{
  imports = [
    ./hardware.nix
    ./desktop.nix
    ./software.nix
  ];
  local.cache.enable = true;
}
