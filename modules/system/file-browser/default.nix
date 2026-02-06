{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.file-browser;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
in
{
  options.local.file-browser = {
    enable = lib.mkEnableOption "Web-based file browser";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Web interface port";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall port for File Browser";
    };

    subPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/files";
      description = "Subpath for reverse proxy (e.g., /files)";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/filebrowser";
      description = "Directory for File Browser database and config";
    };

    rootPath = lib.mkOption {
      type = lib.types.str;
      default = "/media";
      description = "Root path to serve files from";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure configuration directory exists
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    # Create empty database file if it doesn't exist to prevent Docker from creating a directory
    systemd.services.init-filebrowser-db = {
      description = "Initialize File Browser database";
      before = [ "podman-filebrowser.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        touch ${cfg.dataDir}/filebrowser.db
        touch ${cfg.dataDir}/settings.json
      '';
    };

    virtualisation.oci-containers.containers.filebrowser = {
      image = "filebrowser/filebrowser:latest";
      ports = [ "${toString cfg.port}:80" ];
      volumes = [
        "${cfg.rootPath}:/srv"
        "${cfg.dataDir}/filebrowser.db:/database/filebrowser.db"
        "${cfg.dataDir}/settings.json:/.filebrowser.json"
      ];
      environment = {
        PUID = "1000"; # Run as 'tod' (assuming id 1000)
        PGID = "100";  # Run as 'users'
      };
      autoStart = true;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # Enable Podman if not already enabled (though likely is)
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}
