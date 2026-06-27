{
  pkgs,
  config,
  lib,
  modulesPath,
  inputs,
  nodeId,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ../../profiles/base.nix
    ./hardware-configuration.nix
  ];
  boot.isContainer = true;

  networking.useDHCP = false;

  # Allow SSH
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  local = {
    network.useNetworkManager = mkForce false;
    disks.enable = mkForce false;

  };

  networking.firewall.enable = false;
  services.nginx = {
    enable = true;
    virtualHosts.localhost.locations."/index.html".extraConfig = ''
      add_header Content-Type text/plain;
      return 200 "Container: ${config.networking.hostName}\n";
    '';
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  system.stateVersion = "25.11";
}
