{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib) mkDefault mkEnableOption mkIf mkOption types;

  cfg = config.local.gitea;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };

  actualRootUrl = (urlHelpers.buildSubdomainUrl {
    serviceName = "git";
    port = cfg.port;
  }) + "/";

  actualDomain =
    if (config.local.reverse-proxy.enable or false)
    then "git.${urlHelpers.baseDomain}"
    else urlHelpers.baseDomain;
in
{
  options.local.gitea = {
    enable = mkEnableOption "Gitea Git service";

    port = mkOption {
      type = types.port;
      default = 3001;
      description = "HTTP port for Gitea web interface";
    };

    sshPort = mkOption {
      type = types.port;
      default = 2222;
      description = "SSH port for Git operations";
    };

    domain = mkOption {
      type = types.str;
      default = "localhost";
      example = "git.example.com";
      description = "Domain name for Gitea instance";
    };

    rootUrl = mkOption {
      type = types.str;
      default = "http://localhost:${toString cfg.port}/";
      example = "https://git.example.com/";
      description = "Root URL for Gitea";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/gitea";
      description = "Data directory for Gitea";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall ports for Gitea";
    };

  };

  config = mkIf cfg.enable {
    services.gitea = {
      enable = true;
      appName = "Gitea: Git with a cup of tea";

      database = {
        type = "sqlite3";
        path = "${cfg.dataDir}/data/gitea.db";
      };

      settings = {
        server = {
          DOMAIN = actualDomain;
          ROOT_URL = actualRootUrl;
          HTTP_PORT = cfg.port;
          SSH_PORT = cfg.sshPort;
          START_SSH_SERVER = true;
        };

        service = {
          DISABLE_REGISTRATION = false;
          REQUIRE_SIGNIN_VIEW = false;
        };

        session = {
          COOKIE_SECURE = mkDefault false;
        };

        repository = {
          DEFAULT_BRANCH = "main";
        };

        ui = {
          DEFAULT_THEME = "arc-green";
        };

        actions = {
          ENABLED = true;
        };
      };

      stateDir = cfg.dataDir;
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port cfg.sshPort ];
    };
  };
}
