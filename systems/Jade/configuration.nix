{ pkgs, config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/virtualisation/lxc-container.nix")
    ../profiles/base.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "Jade";

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.isContainer = true;

  local = {
    # System settings
    disks.enable = false;
    secrets.enable = true;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "harmonia_key"
      "onix_creds"
      "gog_creds"
    ];
  };

  users.users.tod = {
    isNormalUser = true;
    extraGroups = [ "wheel" "incus-admin" ];
    shell = pkgs.fish;
    initialPassword = "rockman";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM227AYpwEQOxdXY4lL4MKVtft2ooiM7nrpMjVED/kAt tod@Onix"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM227AYpwEQOxdXY4lL4MKVtft2ooiM7nrpMjVED/kAt tod@Onix"
  ];

  system.stateVersion = "25.11";
}
