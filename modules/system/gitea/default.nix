{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.gitea;
  hostsCfg = config.local.hosts;
  reverseProxyCfg = config.local.reverse-proxy;
  
  # Determine the actual ROOT_URL based on reverse proxy configuration
  actualRootUrl = 
    if reverseProxyCfg.enable or false
    then
      let
        protocol = "https";
        domain = reverseProxyCfg.domain or cfg.domain;
      in "${protocol}://${domain}" + (if cfg.subPath != "" then cfg.subPath else "") + "/"
    else
      cfg.rootUrl + (if cfg.subPath != "" then cfg.subPath + "/" else "");
in
{
  options.local.gitea = {
    enable = lib.mkEnableOption "Gitea Git service";
    
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "HTTP port for Gitea web interface";
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = "SSH port for Git operations";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "git.example.com";
      description = "Domain name for Gitea instance";
    };

    rootUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:${toString cfg.port}/";
      example = "https://git.example.com/";
      description = "Root URL for Gitea";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/gitea";
      description = "Data directory for Gitea";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall ports for Gitea";
    };

    subPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/gitea";
      description = "Subpath for reverse proxy (e.g., /gitea for https://host/gitea)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;
      appName = "Gitea: Git with a cup of tea";
      
      database = {
        type = "sqlite3";
        path = "${cfg.dataDir}/data/gitea.db";
      };

      settings = {
        server = {
          DOMAIN = if reverseProxyCfg.enable or false then reverseProxyCfg.domain or cfg.domain else cfg.domain;
          ROOT_URL = actualRootUrl;
          HTTP_PORT = cfg.port;
          SSH_PORT = cfg.sshPort;
        };

        service = {
          DISABLE_REGISTRATION = true;
          REQUIRE_SIGNIN_VIEW = false;
        };

        session = {
          COOKIE_SECURE = lib.mkDefault false;
        };

        repository = {
          DEFAULT_BRANCH = "main";
        };

        ui = {
          DEFAULT_THEME = "arc-green";
        };
      };

      stateDir = cfg.dataDir;
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port cfg.sshPort ];
    };
  };
}
