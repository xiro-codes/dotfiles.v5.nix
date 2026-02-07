# HTTPS Reverse Proxy Setup

This configuration provides automatic HTTPS with subdomain-based routing for all server services.

## Overview

The reverse proxy module (`modules/system/reverse-proxy`) provides:
- **Automatic HTTPS** with self-signed certificates (local) or Let's Encrypt (public)
- **Subdomain-based routing** (e.g., `https://git.host.local`, `https://jellyfin.host.local`)
- **Avahi/mDNS integration** - automatically uses `.local` domains when enabled
- **WebSocket support** for services that need it
- **Nginx** as the reverse proxy engine

## Quick Start

### 1. Enable the Reverse Proxy

```nix
local.reverse-proxy = {
  enable = true;
  
  # For local networks with .local domains (default)
  useACME = false;
  domain = "hostname.local"; # Usually auto-configured via Avahi

  # For public domains with Let's Encrypt
  # useACME = true;
  # acmeEmail = "admin@example.com";
  # domain = "example.com";
  
  services = {
    # Services are automatically added when enabled if they integrate with reverse-proxy
    # Or you can add custom ones:
    custom-app = {
      target = "http://localhost:8080";
    };
  };
};
```

### 2. Configure Services

Most modules automatically register themselves with the reverse proxy when enabled.
For example, enabling Gitea will automatically create `git.hostname.local`.

```nix
local.gitea.enable = true;
# Creates https://git.hostname.local -> http://localhost:3001
```

### 3. Access Your Services

With Avahi enabled:
- `https://git.hostname.local`
- `https://jellyfin.hostname.local`
- `https://transmission.hostname.local`

Without Avahi (using static DNS or hosts file):
- `https://git.example.com`
- `https://jellyfin.example.com`

## Supported Services

The following modules automatically integrate with the reverse proxy:

| Service | Module | Subdomain | Default Port |
|---------|--------|-----------|--------------|
| Gitea | `local.gitea` | `git` | 3001 |
| Jellyfin | `local.media.jellyfin` | `jellyfin` | 8096 |
| Plex | `local.media.plex` | `plex` | 32400 |
| ErsatzTV | `local.media.ersatztv` | `ersatztv` | 8409 |
| Transmission | `local.download.transmission` | `transmission` | 9091 |
| Pinchflat | `local.download.pinchflat` | `pinchflat` | 8945 |
| Dashboard | `local.dashboard` | `dashboard` (or root) | 3000 |
| File Browser | `local.file-browser` | `files` | 8999 |

## SSL Certificates

### Self-Signed (Local Networks)

When `useACME = false`, the reverse proxy generates self-signed certificates:
- Valid for 10 years
- Includes Subject Alternative Names for hostname and `*.domain`
- **Browser warning**: You'll need to accept the certificate in your browser

To trust the certificate system-wide, export it and add to your trusted CAs.

### Let's Encrypt (Public Domains)

When `useACME = true`:
```nix
local.reverse-proxy = {
  enable = true;
  useACME = true;
  acmeEmail = "your-email@example.com";
  domain = "example.com"; # Must be publicly resolvable
};
```

Requirements:
- Domain must resolve to your server's public IP
- Ports 80 and 443 must be accessible from the internet
- Email is required for ACME account
- Wildcard DNS is recommended if using many subdomains

## Advanced Configuration

### Custom Nginx Configuration

Add extra Nginx config per service:

```nix
local.reverse-proxy.services = {
  myservice = {
    target = "http://localhost:8080";
    extraConfig = ''
      client_max_body_size 100M;
      proxy_read_timeout 300s;
    '';
  };
};
```

### Firewall

The reverse proxy automatically:
- Opens ports 80 and 443
- Keeps service ports closed (when individual `openFirewall = false`)
- All external access goes through HTTPS

## Troubleshooting

### Certificate Warnings

Self-signed certificates will show browser warnings. This is normal for local networks.

**Firefox**: Click "Advanced" -> "Accept the Risk and Continue"
**Chrome**: Type `thisisunsafe` on the warning page

### Service Not Accessible

1. Check service is running: `systemctl status <service>`
2. Check Nginx config: `nginx -t`
3. Check logs: `journalctl -u nginx -f`
4. Verify DNS resolution: `ping git.hostname.local`

### Avahi Not Working

Ensure the network module has Avahi enabled:
```nix
local.network.enable = true;
```

And hosts module has Avahi enabled:
```nix
local.hosts.useAvahi = true;
```

### ACME Failures

If Let's Encrypt fails:
1. Verify domain DNS points to your server
2. Check ports 80/443 are accessible
3. Review logs: `journalctl -u acme-<domain> -f`
4. Ensure email is provided in `acmeEmail`
