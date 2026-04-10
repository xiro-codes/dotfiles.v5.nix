{ config, ... }:
let
  inherit (config.lib.topology) mkInternet mkRouter mkSwitch mkConnection mkDevice;
in
{
  networks.wan = {
    name = "Internet";
  };

  networks.home = {
    name = "Home Network";
    cidrv4 = "192.168.1.0/24";
  };
  
  networks.zerotier = {
    name = "ZeroTier Virtual Network";
  };

  nodes = {
    # Define dummy interfaces for NixOS hosts so we can connect to them
    Onix.interfaces.enp6s0.network = "home";
    Onix.interfaces.zt0.network = "zerotier";
    Sapphire.interfaces.eth0.network = "home";
    Sapphire.interfaces.zt0.network = "zerotier";
    Ruby.interfaces.eth0.network = "home";
    Jade.interfaces."mv-enp6s0".network = "home";
    Jade.interfaces."mv-enp6s0".physicalConnections = [ (mkConnection "Onix" "enp6s0") ];
    
    # Jade runs as a VM inside Onix
    Jade.parent = "Onix";
    Jade.guestType = "vm";
    Jade.name = "Jade (Web/DDNS)";
    Jade.interfaces.wan.network = "wan";
    Jade.interfaces.wan.physicalConnections = [ (mkConnection "internet" "*") ];

    internet = mkInternet {
      connections = mkConnection "att-router" "wan";
    };

    att-router = mkRouter "AT&T Router" {
      info = "ISP Gateway & Router";
      interfaces.wan.network = "wan";
      interfaces.lan.network = "home";
      connections.lan = mkConnection "main-switch" "eth0";
    };

    main-switch = mkSwitch "Main Switch" {
      info = "Network Switch";
      interfaceGroups = [ [ "eth0" "eth1" "eth2" "eth3" "eth4" ] ];
      interfaces.eth0.network = "home";
      interfaces.eth1.network = "home";
      interfaces.eth2.network = "home";
      interfaces.eth3.network = "home";
      interfaces.eth4.network = "home";

      connections.eth1 = mkConnection "Onix" "enp6s0";
      connections.eth2 = mkConnection "Sapphire" "eth0";
      connections.eth3 = mkConnection "Ruby" "eth0";
    };

    pihole = mkDevice "Pi-hole" {
      info = "DNS Server (used by all hosts)";
      deviceType = "device";
      parent = "Onix";
      guestType = "container";
      interfaces.eth0.network = "home";
    };

    phone = mkDevice "Mobile Phone" {
      info = "ZeroTier Client";
      deviceType = "device";
      interfaces.wifi.network = "wan";
      interfaces.zt0.network = "zerotier";
      connections.wifi = mkConnection "internet" "*";
      connections.zt0 = [
        (mkConnection "Onix" "zt0")
        (mkConnection "Sapphire" "zt0")
      ];
    };
  };
}