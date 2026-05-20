{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet
    mkRouter
    mkSwitch
    mkConnection
    mkDevice
    ;
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
      interfaceGroups = [
        [
          "eth0"
          "eth1"
          "eth2"
          "eth3"
          "eth4"
        ]
      ];
      interfaces.eth0.network = "home";
      interfaces.eth1.network = "home";
      interfaces.eth2.network = "home";
      interfaces.eth3.network = "home";
      interfaces.eth4.network = "home";

      connections.eth1 = mkConnection "Onix" "enp6s0";
      connections.eth2 = mkConnection "Sapphire" "eth0";
      connections.eth3 = mkConnection "Ruby" "eth0";
      connections.eth4 = mkConnection "Slate" "wlan0";
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
