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

  cfg = config.local.media;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
in
{
  options.local.media = {
    enable = mkEnableOption "media server stack";

    mediaDir = mkOption {
      type = types.str;
      default = "/media/Media";
      example = "/media/Media";
      description = "Base directory for media files";
    };

    jellyfin = {
      enable = mkEnableOption "Jellyfin media server";

      port = mkOption {
        type = types.port;
        default = 8096;
        description = "HTTP port for Jellyfin";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall port for Jellyfin";
      };
    };

    plex = {
      enable = mkEnableOption "Plex Media Server";

      port = mkOption {
        type = types.port;
        default = 32400;
        description = "HTTP port for Plex";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall port for Plex";
      };
    };

    ersatztv = {
      enable = mkEnableOption "ErsatzTV streaming service";

      port = mkOption {
        type = types.port;
        default = 8409;
        description = "HTTP port for ErsatzTV";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall port for ErsatzTV";
      };
    };

    komga = {
      enable = mkEnableOption "Komga comic/manga server";

      port = mkOption {
        type = types.port;
        default = 8092;
        description = "HTTP port for Komga";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall port for Komga";
      };
    };

    audiobookshelf = {
      enable = mkEnableOption "Audiobookshelf audiobook server";

      port = mkOption {
        type = types.port;
        default = 13378;
        description = "HTTP port for Audiobookshelf";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall port for Audiobookshelf";
      };
    };
  };

  config = mkIf cfg.enable {
    # Jellyfin
    services.jellyfin = mkIf cfg.jellyfin.enable {
      enable = true;
      openFirewall = cfg.jellyfin.openFirewall;
    };

    # Plex
    services.plex = mkIf cfg.plex.enable {
      enable = true;
      openFirewall = cfg.plex.openFirewall;
    };

    services.ersatztv = mkIf cfg.ersatztv.enable {
      enable = true;
      openFirewall = cfg.ersatztv.openFirewall;
    };

    # Komga
    services.komga = mkIf cfg.komga.enable {
      enable = true;
      openFirewall = cfg.komga.openFirewall;
      settings.server.port = cfg.komga.port;
      settings.server.address = "127.0.0.1";
    };

    # Audiobookshelf
    services.audiobookshelf = mkIf cfg.audiobookshelf.enable {
      enable = true;
      openFirewall = cfg.audiobookshelf.openFirewall;
      port = cfg.audiobookshelf.port;
    };
  };
}
