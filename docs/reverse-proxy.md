# reverse-proxy

This module provides a reverse proxy configuration using Nginx, with support for automatic HTTPS via Let's Encrypt or self-signed certificates. It allows you to easily expose internal services and shared folders to the web using a consistent domain structure.

## Options

Here's a detailed breakdown of the configuration options available:

### `local.reverse-proxy.enable`

**Type:** boolean

**Default:** `false`

**Description:** Enables the reverse proxy with automatic HTTPS. When enabled, this module configures Nginx to act as a reverse proxy for the specified services and shared folders.  It also handles SSL certificate generation and renewal (either via Let's Encrypt or self-signed).

### `local.reverse-proxy.acmeEmail`

**Type:** string

**Default:** `""`

**Example:** `"admin@example.com"`

**Description:** Email address for ACME/Let's Encrypt certificates.  This email will be associated with your Let's Encrypt account and used for important notifications (e.g., certificate expiration warnings).  This option is required when using `useACME = true`.

### `local.reverse-proxy.useACME`

**Type:** boolean

**Default:** `false`

**Description:** Whether to use Let's Encrypt for HTTPS (requires a public domain). If set to `true`, the module will attempt to obtain and renew SSL certificates from Let's Encrypt for your domain. This requires that your domain points to the server running this module and that port 80 is accessible for the ACME challenge. If `false`, self-signed certificates will be generated.

### `local.reverse-proxy.domain`

**Type:** string

**Default:** `"localhost"`

**Example:** `"server.example.com"`

**Description:** Primary domain name for the reverse proxy. This domain will be used as the base domain for all proxied services and shared folders. For example, if the domain is `example.com` and you have a service named `gitea`, it will be accessible at `gitea.example.com`.

### `local.reverse-proxy.openFirewall`

**Type:** boolean

**Default:** `true`

**Description:** Open firewall ports 80 and 443.  If set to `true`, the module will automatically open ports 80 (HTTP) and 443 (HTTPS) on the system firewall, allowing external access to the reverse proxy. If you are managing your firewall separately, you may want to set this to `false`.

### `local.reverse-proxy.sharedFolders`

**Type:** attribute set of paths

**Default:** `{}`

**Example:**

```nix
{
  games = "/media/Media/games";
  wallpapers = "/media/Media/wallpapers";
}
```

**Description:**  Path on disk to serve at `files.onix.home`. This allows you to easily share files and directories over HTTP(S).  Each attribute in the set represents a subdomain, and its value is the path to the directory to be served.  For example, with the example above, the contents of `/media/Media/games` would be accessible at `games.onix.home` (assuming `domain = "onix.home"`).

### `local.reverse-proxy.services`

**Type:** attribute set of submodules

**Default:** `{}`

**Example:**

```nix
{
  gitea.target = "http://localhost:3001";
  my-app = {
    target = "http://localhost:8080";
    extraConfig = ''
      proxy_set_header X-Custom-Header "my-app";
    '';
  };
}
```

**Description:** Services to proxy.  This option defines the services that will be proxied by Nginx.  Each attribute in the set represents a service, and its value is a submodule with the following options:

  *   **`target` (string):** Backend target (e.g., `http://localhost:3001`). This is the URL of the internal service that you want to expose via the reverse proxy.
  *   **`extraConfig` (string):** Extra Nginx configuration for this location. This allows you to add custom Nginx configuration to the service's location block. This is useful for advanced configurations such as custom headers, caching rules, or authentication. Each line should be a valid nginx config directive.

