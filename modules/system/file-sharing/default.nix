{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    literalExpression
    mapAttrs
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.file-sharing;

  # Convert structured definitions to Samba share format
  structuredSambaShares = mapAttrs (name: share: {
    path = share.path;
    comment = mkIf (share.comment != "") share.comment;
    "read only" = if share.readOnly then "yes" else "no";
    "guest ok" = if share.guestOk then "yes" else "no";
    browseable = if share.browseable then "yes" else "no";
    writeable = if share.writeable && !share.readOnly then "yes" else "no";
    "create mask" = share.createMask;
    "directory mask" = share.directoryMask;
    "valid users" = mkIf (share.validUsers != [ ]) (concatStringsSep " " share.validUsers);
  }) cfg.definitions;

  # Merge manual shares with structured shares
  allSambaShares = cfg.samba.shares // structuredSambaShares;

  # Generate NFS exports from structured definitions
  nfsExportsFromDefinitions = concatStringsSep "\n" (
    mapAttrsToList (
      name: share:
      if share.enableNFS then
        "${share.path} ${share.nfsClients}(${concatStringsSep "," share.nfsOptions})"
      else
        ""
    ) cfg.definitions
  );

  # Combine manual NFS exports with generated ones
  allNFSExports = concatStringsSep "\n" [
    cfg.nfs.exports
    nfsExportsFromDefinitions
  ];

  # Get all share directories that need to be created
  shareDirsToCreate = mapAttrsToList (name: share: share.path) cfg.definitions;
in
{
  options.local.file-sharing = {
    enable = mkEnableOption "file sharing services";

    shareDir = mkOption {
      type = types.str;
      default = "/srv/shares";
      example = "/mnt/storage/shares";
      description = "Base directory for shared files";
    };

    nfs = {
      enable = mkEnableOption "NFS server";

      exports = mkOption {
        type = types.lines;
        default = "";
        example = ''
          /srv/shares 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
          /srv/media 192.168.1.0/24(ro,sync,no_subtree_check)
        '';
        description = "NFS exports configuration";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall ports for NFS";
      };
    };

    samba = {
      enable = mkEnableOption "Samba server";

      workgroup = mkOption {
        type = types.str;
        default = "WORKGROUP";
        description = "Samba workgroup name";
      };

      serverString = mkOption {
        type = types.str;
        default = "NixOS File Server";
        description = "Server description string";
      };

      shares = mkOption {
        type = types.attrsOf (types.attrsOf types.unspecified);
        default = { };
        example = literalExpression ''
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

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall ports for Samba";
      };
    };

    # Structured share definitions
    definitions = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.path;
              description = "Absolute path to the share directory";
            };

            comment = mkOption {
              type = types.str;
              default = "";
              description = "Description of the share";
            };

            readOnly = mkOption {
              type = types.bool;
              default = false;
              description = "Whether the share is read-only";
            };

            guestOk = mkOption {
              type = types.bool;
              default = false;
              description = "Allow guest access without authentication";
            };

            browseable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether the share is visible in browse lists";
            };

            validUsers = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [
                "alice"
                "bob"
              ];
              description = "List of users allowed to access (empty = all users)";
            };

            writeable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether users can write to the share";
            };

            createMask = mkOption {
              type = types.str;
              default = "0666";
              description = "Permissions mask for created files";
            };

            directoryMask = mkOption {
              type = types.str;
              default = "0777";
              description = "Permissions mask for created directories";
            };

            enableNFS = mkOption {
              type = types.bool;
              default = false;
              description = "Also export this share via NFS";
            };

            nfsOptions = mkOption {
              type = types.listOf types.str;
              default = [
                "rw"
                "sync"
                "no_subtree_check"
              ];
              description = "NFS export options";
            };

            nfsClients = mkOption {
              type = types.str;
              default = "192.168.0.0/16";
              example = "192.168.1.0/24";
              description = "Network range for NFS access";
            };
          };
        }
      );
      default = { };
      example = literalExpression ''
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

  config = mkIf cfg.enable {
    # Ensure share directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.shareDir} 0755 root root -"
      "d ${cfg.shareDir}/public 0777 root root -"
      "d ${cfg.shareDir}/private 0750 root root -"
    ]
    ++ (map (path: "d ${path} 0777 root root -") shareDirsToCreate);

    # NFS Server
    services.nfs.server = mkIf cfg.nfs.enable {
      enable = true;
      exports = allNFSExports;

      # Use NFSv4
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
    };

    networking.firewall = mkIf cfg.nfs.openFirewall {
      allowedTCPPorts = [
        111
        2049
        4000
        4001
        4002
        20048
      ];
      allowedUDPPorts = [
        111
        2049
        4000
        4001
        4002
        20048
      ];
    };

    # Samba Server
    services.samba = mkIf cfg.samba.enable {
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
      }
      // allSambaShares;
    };

    services.samba-wsdd = mkIf cfg.samba.enable {
      enable = true;
      openFirewall = cfg.samba.openFirewall;
    };
  };
}
