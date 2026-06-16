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

  networks.vpn = {
    name = "ProtonVPN (WireGuard)";
  };

  networks.zerotier = {
    name = "ZeroTier Virtual Network";
  };

  nodes = {
    internet = mkInternet {
      connections = mkConnection "att-router" "wan";
    };

    proton_vpn = mkInternet {
      info = "ProtonVPN Endpoint";
      connections = mkConnection "Sapphire" "wg0";
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
        ]
      ];
      interfaces.eth0.network = "home";
      interfaces.eth1.network = "home";
      interfaces.eth2.network = "home";
      interfaces.eth3.network = "home";

      connections.eth1 = mkConnection "Sapphire" "enp8s0";
      connections.eth2 = mkConnection "Ruby" "enp7s0";
      connections.eth3 = mkConnection "Slate" "enp4s0f3u1u3";
    };

    phone = mkDevice "Mobile Phone" {
      info = "ZeroTier Client";
      deviceType = "device";
      interfaces.wifi.network = "wan";
      interfaces.zt0.network = "zerotier";
      connections.wifi = mkConnection "internet" "*";
    };
  };
}
