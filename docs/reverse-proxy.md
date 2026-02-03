# HTTPS Reverse Proxy Setup

This configuration provides automatic HTTPS with path-based routing for all server services.

## Overview

The reverse proxy module (`modules/system/reverse-proxy`) provides:
- **Automatic HTTPS** with self-signed certificates (local) or Let's Encrypt (public)
- **Path-based routing** (e.g., `https://host/gitea`, `https://host/jellyfin`)
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
  
  # For public domains with Let's Encrypt
  # useACME = true;
  # acmeEmail = "admin@example.com";
  
  services = {
    gitea = {
      path = "/gitea";
      target = "http://localhost:3001";
    };
    # Add more services...
  };
};
```

### 2. Configure Services with subPath

Each service needs to know it's behind a reverse proxy:

```nix
local.gitea = {
  enable = true;
  subPath = "/gitea";  # Must match reverse-proxy path
  openFirewall = false; # Proxy handles external access
};
```

### 3. Access Your Services

With Avahi enabled:
- `https://hostname.local/gitea`
- `https://hostname.local/jellyfin`
- `https://hostname.local/transmission`

Without Avahi:
- `https://10.0.0.65/gitea`
- `https://10.0.0.65/jellyfin`
- `https://10.0.0.65/transmission`

## Supported Services

All server modules support `subPath` configuration:

| Service | Module | Default Port | Example Path |
|---------|--------|--------------|--------------|
| Gitea | `local.gitea` | 3001 | `/gitea` |
| Jellyfin | `local.media.jellyfin` | 8096 | `/jellyfin` |
| Plex | `local.media.plex` | 32400 | `/plex` |
| ErsatzTV | `local.media.ersatztv` | 8409 | `/ersatztv` |
| Transmission | `local.download.transmission` | 9091 | `/transmission` |
| Pinchflat | `local.download.pinchflat` | 8945 | `/pinchflat` |
| Dashboard | `local.dashboard` | 3000 | `/dashboard` |
| Nix Cache | `local.cache-server` | 8080 | `/cache` |

## Complete Example

See `systems/profiles/server-example.nix` for a complete working configuration.

## SSL Certificates

### Self-Signed (Local Networks)

When `useACME = false`, the reverse proxy generates self-signed certificates:
- Valid for 10 years
- Includes Subject Alternative Names for hostname and IP
- **Browser warning**: You'll need to accept the certificate in your browser

To trust the certificate system-wide, export it and add to your trusted CAs.

### Let's Encrypt (Public Domains)

When `useACME = true`:
```nix
local.reverse-proxy = {
  enable = true;
  useACME = true;
  acmeEmail = "your-email@example.com";
  domain = "server.example.com"; # Must be publicly resolvable
};
```

Requirements:
- Domain must resolve to your server's public IP
- Ports 80 and 443 must be accessible from the internet
- Email is required for ACME account

## Service-Specific Notes

### Gitea
- Automatically configures `ROOT_URL` when `subPath` is set
- SSH access still uses the configured SSH port (default 2222)

### Jellyfin
- Supports base URL natively
- Works well with subpaths

### Plex
- Limited subpath support
- May require additional configuration in Plex settings
- Network settings → Custom server access URLs

### Transmission
- Automatically configures RPC URL when `subPath` is set
- Web interface works correctly with reverse proxy

### Dashboard (Homepage)
- Can serve as a landing page with links to all services
- Consider using it as the root path (`/`)

## Advanced Configuration

### Custom Nginx Configuration

Add extra Nginx config per service:

```nix
services = {
  myservice = {
    path = "/myservice";
    target = "http://localhost:8080";
    extraConfig = ''
      client_max_body_size 100M;
      proxy_read_timeout 300s;
    '';
  };
};
```

### Multiple Domains

The current setup supports a single domain. For multiple domains, you can:
1. Create multiple virtual host configurations
2. Use wildcard certificates
3. Add more entries to `services.nginx.virtualHosts`

### Firewall

The reverse proxy automatically:
- Opens ports 80 and 443
- Keeps service ports closed (when `openFirewall = false`)
- All external access goes through HTTPS

## Troubleshooting

### Certificate Warnings

Self-signed certificates will show browser warnings. This is normal for local networks.

**Firefox**: Click "Advanced" → "Accept the Risk and Continue"
**Chrome**: Type `thisisunsafe` on the warning page

### Service Not Accessible

1. Check service is running: `systemctl status <service>`
2. Check Nginx config: `nginx -t`
3. Check logs: `journalctl -u nginx -f`
4. Verify subPath matches between service and reverse-proxy config

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

## Security Considerations

- Self-signed certificates provide encryption but not authentication
- For untrusted networks, use Let's Encrypt with a real domain
- Keep services updated
- Consider adding authentication to services that don't have it
- Use firewall rules to restrict access to trusted networks
- Regularly review Nginx access logs

## Integration with Hosts Module

The reverse proxy automatically integrates with your hosts configuration:

```nix
local.hosts = {
  useAvahi = true;  # Use .local domains
};
```

When enabled, reverse proxy will:
- Use `hostname.local` as the domain
- Generate certificates with `.local` SANs
- Work seamlessly with mDNS/Avahi discovery
