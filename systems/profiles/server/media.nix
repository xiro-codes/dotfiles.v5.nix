{ config, ... }:
{
  local = {
    # Old media/downloads modules disabled — replaced by nixarr-stack
    media.enable = true;
    downloads.enable = true;

    # New nixarr-based media stack
    nixarr-stack = {
      enable = false;
      mediaDir = "/media/Media";
      vpn.enable = true;
    };

    gog-downloader = {
      enable = false;
      directory = "/media/Media/games";
      secretFile = config.sops.secrets."gog_creds".path;
    };
  };
}
