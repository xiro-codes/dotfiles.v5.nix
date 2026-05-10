{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.rocket-forge;
  pkg = self.packages.${pkgs.system}.default;
in
{
  options.services.rocket-forge = {
    enable = mkEnableOption "Rocket Forge Service";

    package = mkOption {
      type = types.package;
      default = pkg;
      description = "The package to use for the rocket-forge services.";
    };

    databaseUrl = mkOption {
      type = types.str;
      default = "postgres://rocket_blog:rocket_blog@localhost/rocket_blog";
      description = "Database connection string.";
    };

    manageDatabase = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically configure a local PostgreSQL database for this service.";
    };

    enableSeeding = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable database seeding with sample data.";
    };

    databaseDataDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to store PostgreSQL database data. If null, uses the default.";
    };

    defaultAdminUsername = mkOption {
      type = types.str;
      default = "admin";
      description = "Default admin username to create if the database is empty.";
    };

    defaultAdminPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default admin password to create if the database is empty.";
    };

    secretKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a file containing ROCKET_SECRET_KEY=... for session encryption.";
    };

    rocketProfile = mkOption {
      type = types.str;
      default = "release";
      description = "The ROCKET_PROFILE to use (e.g. 'release' or 'debug').";
    };

    workingDirectory = mkOption {
      type = types.str;
      default = "${cfg.package}/share/rocket-blog";
      description = "Working directory for the services. Override this for development to point to local templates/static.";
    };

    port = mkOption {
      type = types.port;
      default = 8000;
      description = "Port for the unified Rocket Forge service.";
    };

    domain = mkOption {
      type = types.str;
      default = "_";
      description = "Domain name for the nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = mkIf cfg.manageDatabase {
      enable = true;
      dataDir = mkIf (cfg.databaseDataDir != null) cfg.databaseDataDir;
      ensureDatabases = [ "rocket_blog" ];
      ensureUsers = [
        {
          name = "rocket_blog";
          ensureDBOwnership = true;
        }
      ];
      authentication = pkgs.lib.mkOverride 10 ''
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
      '';
    };

    services.redis.enable = true;

    systemd.services.rocket-forge = {
      description = "Rocket Forge Unified Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "redis.service" ] ++ (if cfg.manageDatabase then [ "postgresql.service" ] else [ ]);
      environment = {
        ROCKET_PROFILE = cfg.rocketProfile;
        ROCKET_PORT = toString cfg.port;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_DATABASES__SEA_ORM__URL = cfg.databaseUrl;
        DEFAULT_ADMIN_USERNAME = cfg.defaultAdminUsername;
        ENABLE_SEEDING = if cfg.enableSeeding then "true" else "false";
      }
      // lib.optionalAttrs (cfg.defaultAdminPassword != null) {
        DEFAULT_ADMIN_PASSWORD = cfg.defaultAdminPassword;
      };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/app";
        WorkingDirectory = cfg.workingDirectory;
        EnvironmentFile = mkIf (cfg.secretKeyFile != null) cfg.secretKeyFile;
        Restart = "always";
        DynamicUser = true;
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };
}
