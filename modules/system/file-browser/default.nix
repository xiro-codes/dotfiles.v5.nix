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

  cfg = config.local.file-browser;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
in
{
  options.local.file-browser = {
    enable = mkEnableOption "Web-based file browser";

    port = mkOption {
      type = types.port;
      default = 8999;
      description = "Web interface port";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall port for File Browser";
    };

    rootPath = mkOption {
      type = types.str;
      default = "/media";
      description = "Root path to serve files from";
    };
  };

  config = mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      openFirewall = cfg.openFirewall;
      settings = {
        port = cfg.port;
        root = cfg.rootPath;
        noauth = true;
        username = "admin";
      };
    };
  };
}
