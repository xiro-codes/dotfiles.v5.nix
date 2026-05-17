{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/server
  ];
  local = {
    # System settings
    bootloader.recoveryUUID = "017aa821-7b75-492a-98cf-1174f1b15ea1";

    secrets.keys = [
      "harmonia_key"
      "gog_creds"
      "zerotier_network_id"
      "gitea/runner_token"
    ];
    zerotier.enable = true;
    containers.Jade.enable = true;
    virtualisation.incus.enable = false;
    cluster.size = 0;
  };

  users.users.tod.extraGroups = [
    "minecraft"
    "incus-admin"
  ];
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
      "tcpstat"
      "diskstats"
    ];
  };
  services.prometheus = {
    enable = true;
    port = 9090;

    globalConfig = {
      scrape_interval = "15s";
    };

    # Tell Prometheus exactly where to pull metrics from
    scrapeConfigs = [
      {
        job_name = "nixos-node";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "harmonia-cache";
        static_configs = [
          {
            # Harmonia exposes standard prometheus metrics natively at /metrics
            targets = [ "127.0.0.1:5000" ];
          }
        ];
      }
    ];

    # Optional: Increase data retention beyond the default 15 days
    extraFlags = [
      "--storage.tsdb.retention.time=30d"
    ];
  };
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 2938;
        enforce_domain = false;
        enable_gzip = true;
        domain = "pihole.onix.home";
      };
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
    };
  };
  boot = {
    swraid.mdadmConf = "MAILADDR root";
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
  };

  networking.nftables.enable = true;

  system.stateVersion = "25.11";
}
