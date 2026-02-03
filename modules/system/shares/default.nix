{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.shares;
  hostsCfg = config.local.hosts;
  
  # Helper to get current host address
  currentAddress = 
    if hostsCfg.useAvahi
    then "${config.networking.hostName}.local"
    else if builtins.hasAttr config.networking.hostName hostsCfg
         then hostsCfg.${config.networking.hostName}
         else config.networking.hostName;
in
{
  options.local.shares = {
    enable = lib.mkEnableOption "file sharing services";

    shareDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/shares";
      example = "/mnt/storage/shares";
      description = "Base directory for shared files";
    };

    nfs = {
      enable = lib.mkEnableOption "NFS server";
      
      exports = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = ''
          /srv/shares 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
          /srv/media 192.168.1.0/24(ro,sync,no_subtree_check)
        '';
        description = "NFS exports configuration";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall ports for NFS";
      };
    };

    samba = {
      enable = lib.mkEnableOption "Samba server";
      
      workgroup = lib.mkOption {
        type = lib.types.str;
        default = "WORKGROUP";
        description = "Samba workgroup name";
      };

      serverString = lib.mkOption {
        type = lib.types.str;
        default = "NixOS File Server";
        description = "Server description string";
      };

      shares = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
        default = {};
        example = lib.literalExpression ''
          {
            public = {
              path = "/srv/shares/public";
              "read only" = "no";
              browseable = "yes";
              "guest ok" = "yes";
            };
            media = {
              path = "/srv/media";
              "read only" = "yes";
              browseable = "yes";
              "guest ok" = "yes";
            };
          }
        '';
        description = "Samba share definitions";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall ports for Samba";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure share directory exists
    systemd.tmpfiles.rules = [
      "d ${cfg.shareDir} 0755 root root -"
      "d ${cfg.shareDir}/public 0777 root root -"
      "d ${cfg.shareDir}/private 0750 root root -"
    ];

    # NFS Server
    services.nfs.server = lib.mkIf cfg.nfs.enable {
      enable = true;
      exports = cfg.nfs.exports;
      
      # Use NFSv4
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
    };

    networking.firewall = lib.mkIf cfg.nfs.openFirewall {
      allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
      allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
    };

    # Samba Server
    services.samba = lib.mkIf cfg.samba.enable {
      enable = true;
      openFirewall = cfg.samba.openFirewall;
      
      settings = {
        global = {
          workgroup = cfg.samba.workgroup;
          "server string" = cfg.samba.serverString;
          "netbios name" = config.networking.hostName;
          security = "user";
          "hosts allow" = "192.168. 10. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          
          # Performance tuning
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=524288 SO_SNDBUF=524288";
          "deadtime" = "30";
          "use sendfile" = "yes";
          "write cache size" = "262144";
          "min receivefile size" = "16384";
          "aio read size" = "16384";
          "aio write size" = "16384";
        };
      } // cfg.samba.shares;
    };

    services.samba-wsdd = lib.mkIf cfg.samba.enable {
      enable = true;
      openFirewall = cfg.samba.openFirewall;
    };
  };
}
