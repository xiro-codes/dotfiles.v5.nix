{ pkgs, config, lib, modulesPath, inputs, ... }: {
  imports = [
    ../profiles/base.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "Cinnabar";
  boot.isContainer = true;

  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    networks."50-macvlan" = {
      matchConfig.Name = "mv-enp6s0";
      networkConfig = {
        DHCP = "ipv4";
      };
    };
  };

  # Allow SSH
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  local = {
    network.useNetworkManager = lib.mkForce false;
    disks.enable = false;
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
  services.ddns-updater = {
    enable = true;
    config = {
      settings = [{
        provider = "cloudflare";
        domain = "tdavis.dev";
        ttl = 1;
      }];
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@tdavis.dev";
    certs."cloud.tdavis.dev" = {
      domain = "cloud.tdavis.dev";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/acme/cloudflare.env";
      group = "nginx";
    };
  };
  services.nextcloud = {
    enable = true;
    hostName = "cloud.tdavis.dev";
    https = true;
    config.adminuser = "admin";
    config.adminpassFile = config.sops.secrets."apps/blog_key".path;
    config.dbtype = "sqlite";
  };
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "cloud.tdavis.dev" = {
        forceSSL = false;
        addSSL = true;
        useACMEHost = "cloud.tdavis.dev";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  users.users.tod = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    initialPassword = "rockman";
  };

  system.stateVersion = "25.11";
}
