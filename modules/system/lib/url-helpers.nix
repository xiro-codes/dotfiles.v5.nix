{ config, lib, ... }:

let
  hostsCfg = config.local.hosts;
  reverseProxyCfg = config.local.reverse-proxy;
in
{
  # Get the current hostname
  getHostname = config.networking.hostName or "localhost";
  
  # Get the current host address (IP or .local)
  getHostAddress = 
    let
      hostname = config.networking.hostName or "localhost";
    in
    if hostsCfg.useAvahi
    then "${hostname}.local"
    else if builtins.hasAttr hostname hostsCfg
         then hostsCfg.${hostname}
         else hostname;
  
  # Get the public domain (considering reverse proxy)
  getPublicDomain = 
    if reverseProxyCfg.enable or false
    then reverseProxyCfg.domain or (
      if hostsCfg.useAvahi
      then "${config.networking.hostName or "localhost"}.local"
      else config.networking.hostName or "localhost"
    )
    else config.networking.hostName or "localhost";
  
  # Get the protocol (http or https based on reverse proxy)
  getProtocol = 
    if reverseProxyCfg.enable or false
    then "https"
    else "http";
  
  # Build a full URL for a service
  # buildServiceUrl: { port, subPath ? "" } -> string
  buildServiceUrl = { port, subPath ? "" }:
    let
      protocol = if reverseProxyCfg.enable or false then "https" else "http";
      domain = if reverseProxyCfg.enable or false
               then reverseProxyCfg.domain or (
                 if hostsCfg.useAvahi
                 then "${config.networking.hostName or "localhost"}.local"
                 else config.networking.hostName or "localhost"
               )
               else "localhost";
      portSuffix = if reverseProxyCfg.enable or false then "" else ":${toString port}";
      path = if subPath != "" then subPath else "";
    in
    "${protocol}://${domain}${portSuffix}${path}";
  
  # Get list of allowed hosts (for services that need it)
  getAllowedHosts = 
    let
      hostname = config.networking.hostName or "localhost";
      addresses = [
        hostname
        "localhost"
        "127.0.0.1"
      ] ++ lib.optionals (builtins.hasAttr hostname hostsCfg) [
        hostsCfg.${hostname}
      ] ++ lib.optionals hostsCfg.useAvahi [
        "${hostname}.local"
      ] ++ lib.optionals (reverseProxyCfg.enable or false) [
        reverseProxyCfg.domain or ""
      ];
    in
    lib.unique (lib.filter (x: x != "") addresses);
}
