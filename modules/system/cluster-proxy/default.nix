{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    listToAttrs
    map
    range
    ;
  clusterCfg = config.local.cluster;
  cfg = config.local.cluster-proxy;

  templateLabel =
    if builtins.isFunction clusterCfg.template then
      clusterCfg.nameSpace
    else
      "${clusterCfg.nameSpace}-${lib.strings.toLower clusterCfg.template}";
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
    ];
    services.nginx = {
      enable = true;
      upstreams."${templateLabel}-cluster".servers = listToAttrs (
        map (i: {
          name = "${clusterCfg.subnet}.${toString (i + 1)}";
          value = { };
        }) (range 1 clusterCfg.size)
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
