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
        "textfile"
      ];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
      ];
    };

    systemd.services.nix-metrics-collector = {
      description = "Collect Nix metrics for Prometheus";
      script = ''
        mkdir -p /var/lib/prometheus-node-exporter-text-files
        TMP_FILE=$(mktemp)

        # Number of derivations currently building (approximation by checking nix processes)
        BUILDING=$(ps -eo comm | grep -c "^nix-daemon$")
        echo "nix_derivations_building $BUILDING" >> $TMP_FILE

        # Size of the Nix store in bytes
        STORE_SIZE=$(du -sb /nix/store | awk '{print $1}')
        echo "nix_store_size_bytes $STORE_SIZE" >> $TMP_FILE

        # Number of files that will get garbage collected (approx by finding dead store paths)
        # This can be slow, so we just run a quick GC dry-run
        GC_DRY=$(nix-store --gc --print-dead 2>/dev/null | wc -l)
        echo "nix_dead_store_paths $GC_DRY" >> $TMP_FILE

        mv $TMP_FILE /var/lib/prometheus-node-exporter-text-files/nix-metrics.prom
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
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
