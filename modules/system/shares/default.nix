{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.shares;
  
  # Convert structured definitions to Samba share format
  structuredSambaShares = lib.mapAttrs (name: share: {
    path = share.path;
    comment = lib.mkIf (share.comment != "") share.comment;
    "read only" = if share.readOnly then "yes" else "no";
    "guest ok" = if share.guestOk then "yes" else "no";
    browseable = if share.browseable then "yes" else "no";
    writeable = if share.writeable && !share.readOnly then "yes" else "no";
    "create mask" = share.createMask;
    "directory mask" = share.directoryMask;
    "valid users" = lib.mkIf (share.validUsers != []) (lib.concatStringsSep " " share.validUsers);
  }) cfg.definitions;
  
  # Merge manual shares with structured shares
  allSambaShares = cfg.samba.shares // structuredSambaShares;
  
  # Generate NFS exports from structured definitions
  nfsExportsFromDefinitions = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: share:
      if share.enableNFS
      then "${share.path} ${share.nfsClients}(${lib.concatStringsSep "," share.nfsOptions})"
      else ""
    ) cfg.definitions
  );
  
  # Combine manual NFS exports with generated ones
  allNFSExports = lib.concatStringsSep "\n" [
    cfg.nfs.exports
    nfsExportsFromDefinitions
  ];
  
  # Get all share directories that need to be created
  shareDirsToCreate = lib.mapAttrsToList (name: share: share.path) cfg.definitions;
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

    # Structured share definitions
    definitions = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          path = lib.mkOption {
            type = lib.types.str;
            description = "Absolute path to the share directory";
          };

          comment = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Description of the share";
          };

          readOnly = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether the share is read-only";
          };

          guestOk = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow guest access without authentication";
          };

          browseable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether the share is visible in browse lists";
          };

          validUsers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            example = [ "alice" "bob" ];
            description = "List of users allowed to access (empty = all users)";
          };

          writeable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether users can write to the share";
          };

          createMask = lib.mkOption {
            type = lib.types.str;
            default = "0664";
            description = "Permissions mask for created files";
          };

          directoryMask = lib.mkOption {
            type = lib.types.str;
            default = "0775";
            description = "Permissions mask for created directories";
          };

          enableNFS = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Also export this share via NFS";
          };

          nfsOptions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "rw" "sync" "no_subtree_check" ];
            description = "NFS export options";
          };

          nfsClients = lib.mkOption {
            type = lib.types.str;
            default = "192.168.0.0/16";
            example = "192.168.1.0/24";
            description = "Network range for NFS access";
          };
        };
      });
      default = {};
      example = lib.literalExpression ''
        {
          media = {
            path = "/srv/media";
            comment = "Media files";
            readOnly = true;
            guestOk = true;
            enableNFS = true;
          };
          documents = {
            path = "/srv/documents";
            comment = "Shared documents";
            validUsers = [ "alice" "bob" ];
          };
        }
      '';
      description = "Structured share definitions that automatically configure both Samba and NFS";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure share directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.shareDir} 0755 root root -"
      "d ${cfg.shareDir}/public 0777 root root -"
      "d ${cfg.shareDir}/private 0750 root root -"
    ] ++ (map (path: "d ${path} 0755 root root -") shareDirsToCreate);

    # NFS Server
    services.nfs.server = lib.mkIf cfg.nfs.enable {
      enable = true;
      exports = allNFSExports;
      
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
      } // allSambaShares;
    };

    services.samba-wsdd = lib.mkIf cfg.samba.enable {
      enable = true;
      openFirewall = cfg.samba.openFirewall;
    };
  };
}
