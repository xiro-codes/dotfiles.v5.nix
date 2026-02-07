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
      default = 8999;
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

    rootPath = lib.mkOption {
      type = lib.types.str;
      default = "/media";
      description = "Root path to serve files from";
    };
  };

  config = lib.mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      openFirewall = cfg.openFirewall;
      settings = {
        port = cfg.port;
        root = cfg.roatPath;
      };
    };
  };
}
