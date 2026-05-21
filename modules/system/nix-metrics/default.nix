{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable the custom Nix metrics plugin globally for the daemon
  services.nix-metrics-plugin.enable = true;
}
