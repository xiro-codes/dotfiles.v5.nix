{ pkgs, config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/virtualisation/lxc-container.nix")
    ../profiles/base.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "Jade";
  nix.settings.sandbox = false;
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
    network-hosts.useAvahi = true;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "ssh_pub_jade/master"
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
  };

  system.stateVersion = "25.11";
}
