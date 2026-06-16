{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    listToAttrs
    map
    range
    types
    ;
  inherit (lib) toLower;
  cfg = config.local.cluster-proxy;
  sharedClusterCfg = config.local.shared.cluster;

  templateLabel =
    if builtins.isFunction sharedClusterCfg.template then
      sharedClusterCfg.nameSpace
    else
      "${sharedClusterCfg.nameSpace}-${toLower sharedClusterCfg.template}";
in
{
  options.local.cluster-proxy = {
    enable = mkEnableOption "Nginx reverse proxy for the cluster";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.local.reverse-proxy.enable;
        message = "local.cluster-proxy and local.reverse-proxy cannot be enabled at the same time";
      }
      {
        assertion = config.local.shared ? cluster;
        message = "local.cluster-proxy requires local.shared.cluster to be populated by the cluster module";
      }
    ];
    services.nginx = {
      enable = true;
      upstreams."${templateLabel}-cluster".servers = listToAttrs (
        map (i: {
          name = "${sharedClusterCfg.subnet}.${toString (i + 1)}";
          value = { };
        }) (range 1 sharedClusterCfg.size)
      );
      virtualHosts."localhost" = {
        locations."/" = {
          proxyPass = "http://${templateLabel}-cluster/";
          extraConfig = ''
            default_type text/html; 
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };
}
