{ config, lib, ... }:

let
  cfg = config.local.hosts;
  
  # Define host mappings
  hostDefs = {
    zimaos = {
      ip = "10.0.0.65";
      avahi = "zimaos.local";
    };
    ruby = {
      ip = "10.0.0.66";
      avahi = "ruby.local";
    };
    sapphire = {
      ip = "10.0.0.67";
      avahi = "sapphire.local";
    };
  };
  
  # Helper to get the address for a host
  getHost = name: 
    if cfg.useAvahi 
    then hostDefs.${name}.avahi 
    else hostDefs.${name}.ip;
  
  # Helper to get address for current or any host
  getHostAddress = hostname:
    if builtins.hasAttr hostname hostDefs
    then getHost hostname
    else if cfg.useAvahi
         then "${hostname}.local"
         else hostname;  # fallback to hostname as-is
in
{
  options.local.hosts = {
    useAvahi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use Avahi/mDNS hostnames (.local) instead of raw IP addresses for local network hosts";
    };
    
    # Expose resolved addresses for other modules to use
    zimaos = lib.mkOption {
      type = lib.types.str;
      default = getHost "zimaos";
      readOnly = true;
      description = "Address for ZimaOS server";
    };
    
    ruby = lib.mkOption {
      type = lib.types.str;
      default = getHost "ruby";
      readOnly = true;
      description = "Address for Ruby host";
    };
    
    sapphire = lib.mkOption {
      type = lib.types.str;
      default = getHost "sapphire";
      readOnly = true;
      description = "Address for Sapphire host";
    };
  };
  
  config = {
    # Add entries to /etc/hosts for better reliability
    networking.hosts = lib.mkIf cfg.useAvahi {
      "${hostDefs.zimaos.ip}" = [ "zimaos.local" ];
      "${hostDefs.ruby.ip}" = [ "ruby.local" ];
      "${hostDefs.sapphire.ip}" = [ "sapphire.local" ];
    };
  };
}
