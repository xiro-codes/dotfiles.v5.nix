{ pkgs, config, lib, modulesPath, inputs, ... }: {
  imports = [
    ../../profiles/base.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "Jade";
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
  services.ddns-updater = {
    enable = true;
    config = {
      settings = [
        ({
          provider = "cloudflare";
          domain = "tdavis.dev";
          ttl = 1;
        })
        ({
          provider = "cloudflare";
          domain = "cloud.tdavis.dev";
          ttl = 1;
        })
      ];
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@tdavis.dev";
    certs."tdavis.dev" = {
      domain = "tdavis.dev";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/acme/cloudflare.env";
      group = "nginx";
    };
    certs."cloud.tdavis.dev" = {
      domain = "cloud.tdavis.dev";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/acme/cloudflare.env";
      group = "nginx";
    };
  };
  services.rocket-forge = {
    enable = true;
    domain = "tdavis.dev";
    port = 8081;
    manageDatabase = true;
    secretKeyFile = config.sops.secrets."apps/blog_key".path;
  };
  services.nextcloud = {
    enable = false;
    hostName = "cloud.tdavis.dev";
    config = {
      adminuser = "admin";
      adminpassFile = config.sops.secrets."apps/blog_key".path;
      dbtype = "sqlite";
    };
  };
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "tdavis.dev" = {
        forceSSL = false;
        addSSL = true;
        useACMEHost = "tdavis.dev";
      };
      "cloud.tdavis.dev" = {
        forceSSL = false;
        addSSL = true;
        useACMEHost = "cloud.tdavis.dev";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Note: user 'tod' is automatically managed by local.userManager 
  # which is enabled in profiles/base.nix

  system.stateVersion = "25.11";
}
