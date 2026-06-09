{
  config,
  lib,
  pkgs,
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

    secretKey = mkOption {
      type = types.str;
      default = "SW2YcwTIb9zpOOhoPsMm"; # Can be moved to sops-nix later
      description = "Secret key for Grafana security";
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
      ];
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
        security.secret_key = cfg.secretKey;
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
