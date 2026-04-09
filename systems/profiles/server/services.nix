{ config, ... }:
{
  local = {
    # Dashboard
    dashboard = {
      enable = true;
      allowedHosts = [ config.local.reverse-proxy.domain "localhost" ];
    };
    docs.enable = true;
    harmonia-cache = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."harmonia_key".path ];
      openFirewall = true;
    };
    # Git service
    gitea = {
      enable = true;
      openFirewall = true;
    };
    recovery-builder = {
      enable = true;
    };
    file-browser = {
      enable = false;
      rootPath = "/media/Media/games";
    };
  };
}
