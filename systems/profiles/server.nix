{ config, ... }:
{
  # Example server configuration with HTTPS reverse proxy
  # This shows how to enable all services behind a reverse proxy

  imports = [
    #./server.nix
  ];
  #local.
  # Enable reverse proxy with automatic HTTPS
  local.reverse-proxy = {
    enable = true;
    domain = "onix.local";
    # For local .local domains, uses self-signed certificates
    # For public domains, set useACME = true and provide acmeEmail
    useACME = false;
    acmeEmail = ""; # Set your email if using ACME/Let's Encrypt

    # Domain is auto-configured based on hosts module
    # Will use hostname.local if Avahi is enabled, otherwise IP

    # Configure services with path-based routing
    services = {
      gitea = {
        path = "/gitea";
        target = "http://localhost:${toString config.local.gitea.port}";
      };

      jellyfin = {
        path = "/jellyfin";
        target = "http://localhost:${toString config.local.media.jellyfin.port}";
      };

      plex = {
        path = "/plex";
        target = "http://localhost:${toString config.local.media.plex.port}";
        extraConfig = ''
          # Plex requires special headers
          proxy_set_header X-Plex-Device-Name "NixOS Server";
        '';
      };

      ersatztv = {
        path = "/ersatztv";
        target = "http://localhost:${toString config.local.media.ersatztv.port}";
      };

      transmission = {
        path = "/transmission";
        target = "http://localhost:${toString config.local.download.transmission.port}";
      };

      pinchflat = {
        path = "/pinchflat";
        target = "http://localhost:${toString config.local.download.pinchflat.port}";
      };

      dashboard = {
        path = "/";
        target = "http://localhost:${toString config.local.dashboard.port}";
      };

      cache = {
        path = "/cache";
        target = "http://localhost:${toString config.local.cache-server.port}";
      };
    };
  };

  # Enable services with subPath configured
  local.gitea = {
    enable = true;
    subPath = "/gitea";
    openFirewall = false; # Reverse proxy handles external access
  };

  local.media = {
    enable = true;

    jellyfin = {
      enable = true;
      subPath = "/jellyfin";
      openFirewall = false;
    };

    plex = {
      enable = true;
      subPath = "/plex";
      openFirewall = false;
    };

    ersatztv = {
      enable = true;
      subPath = "/ersatztv";
      openFirewall = false;
    };
  };

  local.download = {
    enable = true;

    transmission = {
      enable = true;
      subPath = "/transmission";
      openFirewall = false;
    };

    pinchflat = {
      enable = true;
      subPath = "/pinchflat";
      openFirewall = false;
    };
  };

  local.dashboard = {
    enable = true;
    subPath = "/";
    openFirewall = false;
  };

  local.cache-server = {
    enable = false;
    subPath = "/cache";
    openFirewall = false;
  };

  # With this configuration, access services via:
  # - https://hostname.local/gitea (if Avahi enabled)
  # - https://ip-address/gitea (if Avahi disabled)
  # - Same pattern for /jellyfin, /plex, /transmission, etc.

  # Note: Self-signed certificates will require browser trust
  # For production, set useACME = true with a public domain
}
