{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.local.network-hosts;

  # Define host mappings
  hostDefs = {
    ruby = {
      ip = "192.168.1.66";
      avahi = "ruby.local";
    };
    sapphire = {
      ip = "192.168.1.67";
      avahi = "sapphire.local";
    };
    slate = {
      ip = "192.168.1.73";
      avahi = "slate.local";
    };
    jade = {
      ip = "192.168.1.68";
      avahi = "jade.local";
    };
  };

  # Helper to get the address for a host
  getHost = name: hostDefs.${name}.ip;

  # Helper to get address for current or any host
  getHostAddress =
    hostname: if builtins.hasAttr hostname hostDefs then getHost hostname else hostname; # fallback to hostname as-is
in
{
  options.local.network-hosts = {

    primary = mkOption {
      type = types.str;
      default = "sapphire";
      description = "The primary host that runs all the centralized services";
    };

    ruby = mkOption {
      type = types.str;
      default = getHost "ruby";
      readOnly = true;
      description = "Address for Ruby host";
    };

    sapphire = mkOption {
      type = types.str;
      default = getHost "sapphire";
      readOnly = true;
      description = "Address for Sapphire host";
    };
    slate = mkOption {
      type = types.str;
      default = getHost "slate";
      readOnly = true;
      description = "Address for Slate host";
    };

  };

  config = {
    # Add entries to /etc/hosts for better reliability
    networking.hosts = {
      "${hostDefs.ruby.ip}" = [
        "ruby"
        "ruby.local"
        "ruby.home"
      ];
      "${hostDefs.sapphire.ip}" = [
        "sapphire"
        "sapphire.local"
        "sapphire.home"
      ];
      "${hostDefs.slate.ip}" = [
        "slate"
        "slate.local"
        "slate.home"
      ];
    };
  };
}
