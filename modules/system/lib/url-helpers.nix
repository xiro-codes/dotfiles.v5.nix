{ config, lib, ... }:

let
  inherit (lib) filter optionals unique;

  hostsCfg = config.local.network-hosts;

  reverseProxyCfg = config.local.reverse-proxy;

  hostname = config.networking.hostName or "localhost";


  # Base domain logic
  baseDomain =
    if reverseProxyCfg.enable
    then reverseProxyCfg.domain
    else if hostsCfg.useAvahi then "${hostname}.local" else hostname;

in
{
  inherit hostname baseDomain;

  # Build a subdomain URL (e.g., https://dl.onix.local)
  buildSubdomainUrl = { serviceName, port }:
    if reverseProxyCfg.enable
    then "https://${serviceName}.${baseDomain}"
    else "http://${baseDomain}:${toString port}";


  # Legacy helper updated for safety
  buildServiceUrl = { port, subPath ? "" }:
    let
      protocol = if reverseProxyCfg.enable then "https" else "http";

      portSuffix =
        if reverseProxyCfg.enable then "" else ":${toString port}";

    in
    "${protocol}://${baseDomain}${portSuffix}${subPath}";

  # Get list of allowed hosts including subdomains
  getAllowedHosts =
    let
      # Extract service names from the reverse proxy config to allow their subdomains
      serviceSubdomains =
        if reverseProxyCfg.enable
        then map (name: "${name}.${baseDomain}") (builtins.attrNames reverseProxyCfg.services)
        else [ ];

      addresses = [
        hostname

        "localhost"

        "127.0.0.1"

        baseDomain
      ] ++ optionals (builtins.hasAttr hostname hostsCfg) [ hostsCfg.${hostname} ]
      ++ serviceSubdomains;
    in
    unique (filter (x: x != "") addresses);

}
