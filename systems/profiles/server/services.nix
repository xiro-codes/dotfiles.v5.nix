{ config, ... }:
{
  local = {
    # Dashboard
    dashboard = {
      enable = true;
      allowedHosts = [ config.local.reverse-proxy.domain "localhost" ];
    };
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
    gitea-runner.enable = true;

    recovery-builder.enable = true;
  };
}
