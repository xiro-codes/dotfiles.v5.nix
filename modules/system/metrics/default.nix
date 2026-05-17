{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.local.metrics;

in
{
  options.local.metrics = {
    enable = mkEnableOption "Prometheus and Grafana metrics";

    prometheusPort = mkOption {
      type = types.port;
      default = 9090;
      description = "Port for Prometheus";
    };

    grafanaPort = mkOption {
      type = types.port;
      default = 2938;
      description = "Port for Grafana";
    };

    domain = mkOption {
      type = types.str;
      default = "metrics.local";
      description = "Domain for Grafana";
    };

  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "systemd"
        "tcpstat"
        "diskstats"
        "textfile"
      ];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
      ];
    };

    systemd.services.nix-metrics-collector = {
      description = "Collect Nix metrics for Prometheus";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.nix-metrics-collector}/bin/nix-metrics-collector";
      };
    };

    systemd.timers.nix-metrics-collector = {
      description = "Run Nix metrics collector every 5 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "nix-metrics-collector.service";
      };
    };

    services.prometheus = {
      enable = true;
      port = cfg.prometheusPort;

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
          http_port = cfg.grafanaPort;
          enforce_domain = false;
          enable_gzip = true;
          domain = cfg.domain;
        };
      };

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:${toString cfg.prometheusPort}";
            isDefault = true;
          }
        ];
        dashboards.settings.providers = [
          {
            name = "Dashboards";
            options.path = ./.; # Since we downloaded the JSON files into the module directory
          }
        ];
      };
    };
  };
}
