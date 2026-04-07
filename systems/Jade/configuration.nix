{ pkgs, config, lib, modulesPath, inputs, ... }: {
  imports = [
    ../profiles/base.nix
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
    disks.enable = false;
    secrets.keys = [
      "ssh_pub_jade/master"
      "ssh_pub_onix/master"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "apps/blog_key"
    ];
  };
  services.ddns-updater = {
    enable = true;
    environment = {
      CONFIG_FILEPATH = "/etc/ddns-updater/config.json";
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@tdavis.dev";
    certs."tdavis.dev" = {
      domain = "tdavis.dev";
      extraDomainNames = [ "blog.tdavis.dev" "worklog.tdavis.dev" ];
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/acme/cloudflare.env";
      group = "nginx";
    };
  };
  services.rocket-blog = {
    enable = true;
    package = inputs.inputs-nix.inputs.rocket-blog.packages.${pkgs.stdenv.hostPlatform.system}.rocket-blog;
    domain = "tdavis.dev";
    worktimeDomain = "worklog.tdavis.dev";
    portfolioDomain = "tdavis.dev";
    manageDatabase = true;
    secretKeyFile = config.sops.secrets."apps/blog_key".path;
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
