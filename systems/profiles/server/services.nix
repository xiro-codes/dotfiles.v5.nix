{ config, ... }:
{
  local = {
    # Dashboard
    dashboard = {
      enable = true;
      allowedHosts = [ config.local.reverse-proxy.domain "localhost" ];
    };
    docs.enable = true;
    # Git service
    gitea = {
      enable = true;
      openFirewall = true;
    };
    gitea-runner.enable = true;
    file-browser = {
      enable = true;
      rootPath = "/media/Media/";
    };
  };
}
