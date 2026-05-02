{
  pkgs,
  config,
  lib,
  modulesPath,
  inputs,
  nodeId,
  ...
}:
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
    network.useNetworkManager = lib.mkForce false;
    disks.enable = lib.mkForce false;
    secrets.keys = [
      "ssh_pub_jade/master"
      "ssh_pub_onix/master"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "apps/blog_key"
      "apps/cloudflare_token"
      "apps/cloudflare_zone_id"
    ];
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
