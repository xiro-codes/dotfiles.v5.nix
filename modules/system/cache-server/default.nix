{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.cache-server;
  hostsCfg = config.local.hosts;
  
  # Helper to get current host address
  currentAddress = 
    if hostsCfg.useAvahi
    then "${config.networking.hostName}.local"
    else if builtins.hasAttr config.networking.hostName hostsCfg
         then hostsCfg.${config.networking.hostName}
         else config.networking.hostName;
  
  # Construct default server URL
  defaultServerUrl = "http://${currentAddress}:${toString cfg.port}";
in
{
  options.local.cache-server = {
    enable = lib.mkEnableOption "Attic binary cache server";
    
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "HTTP port for cache server";
    };

    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = defaultServerUrl;
      description = "Server URL for cache server (auto-configured based on Avahi settings)";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/atticd";
      description = "Data directory for Attic server";
    };

    cacheName = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Name of the cache";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to listen on";
    };

    allowedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "@wheel" ];
      description = "Users allowed to push to the cache";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall port for cache server";
    };

    maxCacheSize = lib.mkOption {
      type = lib.types.str;
      default = "100G";
      example = "500G";
      description = "Maximum cache size (supports K, M, G suffixes)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.atticd = {
      enable = true;
      
      settings = {
        listen = "${cfg.listenAddress}:${toString cfg.port}";
        
        database.url = "sqlite://${cfg.dataDir}/server.db";
        
        storage = {
          type = "local";
          path = "${cfg.dataDir}/storage";
        };

        # Chunking
        chunking = {
          nar-size-threshold = 65536;
          min-size = 16384;
          avg-size = 65536;
          max-size = 262144;
        };

        # Compression
        compression = {
          type = "zstd";
        };

        # Garbage collection
        garbage-collection = {
          interval = "12 hours";
          default-retention-period = "3 months";
        };
      };
    };

    # Environment packages for cache management
    environment.systemPackages = with pkgs; [ 
      attic-server
      attic-client
    ];

    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 atticd atticd -"
      "d ${cfg.dataDir}/storage 0755 atticd atticd -"
    ];

    # Service configuration
    systemd.services.atticd = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "atticd";
        Group = "atticd";
        StateDirectory = "atticd";
      };
    };

    # Create atticd user and group
    users.users.atticd = {
      isSystemUser = true;
      group = "atticd";
      home = cfg.dataDir;
    };

    users.groups.atticd = {};

    # Firewall
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # Setup script for initial cache creation
    system.activationScripts.atticd-setup = lib.mkIf cfg.enable ''
      if [ ! -f ${cfg.dataDir}/.initialized ]; then
        echo "Attic cache server will be initialized on first start"
        echo "Run the following commands to create the cache and get credentials:"
        echo "  sudo -u atticd atticd --mode monolithic &"
        echo "  attic login local http://localhost:${toString cfg.port}"
        echo "  attic cache create ${cfg.cacheName}"
        echo "  attic use ${cfg.cacheName}"
        touch ${cfg.dataDir}/.initialized || true
      fi
    '';
  };
}
