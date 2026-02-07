{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.media;
  urlHelpers = import ../lib/url-helpers.nix { inherit config lib; };
in
{
  options.local.media = {
    enable = lib.mkEnableOption "media server stack";

    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/media/Media";
      example = "/media/Media";
      description = "Base directory for media files";
    };

    jellyfin = {
      enable = lib.mkEnableOption "Jellyfin media server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8096;
        description = "HTTP port for Jellyfin";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Jellyfin";
      };

    };

    plex = {
      enable = lib.mkEnableOption "Plex Media Server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 32400;
        description = "HTTP port for Plex";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Plex";
      };
    };

    ersatztv = {
      enable = lib.mkEnableOption "ErsatzTV streaming service";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8409;
        description = "HTTP port for ErsatzTV";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for ErsatzTV";
      };
    };

    komga = {
      enable = lib.mkEnableOption "Komga comic/manga server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "HTTP port for Komga";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Komga";
      };
    };

    audiobookshelf = {
      enable = lib.mkEnableOption "Audiobookshelf audiobook server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 13378;
        description = "HTTP port for Audiobookshelf";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Audiobookshelf";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Jellyfin
    services.jellyfin = lib.mkIf cfg.jellyfin.enable {
      enable = true;
      openFirewall = cfg.jellyfin.openFirewall;
    };

    # Plex
    services.plex = lib.mkIf cfg.plex.enable {
      enable = true;
      openFirewall = cfg.plex.openFirewall;
    };


    services.ersatztv = lib.mkIf cfg.ersatztv.enable {
      enable = true;
      openFirewall = cfg.ersatztv.openFirewall;
    };

    # Komga
    services.komga = lib.mkIf cfg.komga.enable {
      enable = true;
      openFirewall = cfg.komga.openFirewall;
      port = cfg.komga.port;
    };

    # Audiobookshelf
    services.audiobookshelf = lib.mkIf cfg.audiobookshelf.enable {
      enable = true;
      openFirewall = cfg.audiobookshelf.openFirewall;
      port = cfg.audiobookshelf.port;
    };
  };
}
