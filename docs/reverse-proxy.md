# reverse-proxy

This Nix module provides a reverse proxy with automatic HTTPS support using Nginx. It allows you to easily proxy services running on your local machine or network, serve static files, and automatically configure HTTPS using Let's Encrypt or self-signed certificates.

## Options

### `local.reverse-proxy.enable`

```
Type: boolean
Default: false
```

Enables or disables the reverse proxy functionality.

### `local.reverse-proxy.acmeEmail`

```
Type: string
Default: ""
Example: "admin@example.com"
```

The email address to use for ACME/Let's Encrypt certificate registration. This is required when `useACME` is set to `true`.  Let's Encrypt will use this email to notify you of certificate expiration and other important events.

### `local.reverse-proxy.useACME`

```
Type: boolean
Default: false
```

Determines whether to use Let's Encrypt for automatic HTTPS certificate generation. When set to `true`, a public domain name is required. If set to `false`, self-signed certificates will be used.  Self-signed certificates will cause browser warnings unless manually trusted.

### `local.reverse-proxy.domain`

```
Type: string
Default: "localhost"
Example: "server.example.com"
```

The primary domain name for the reverse proxy.  All subdomains defined in `services` and `sharedFolders` will be appended to this domain.  For example, if `domain` is set to `example.com` and a service named `gitea` is defined, the service will be accessible at `gitea.example.com`.

### `local.reverse-proxy.openFirewall`

```
Type: boolean
Default: true
```

Controls whether to automatically open firewall ports 80 (HTTP) and 443 (HTTPS).  Disabling this requires manually configuring the firewall.

### `local.reverse-proxy.sharedFolders`

```
Type: attribute set of paths
Default: {}
Example:
{
  games = "/media/Media/games";
  wallpapers = "/media/Media/wallpapers";
}
```

An attribute set defining paths on the disk to serve as static files under a `files` subdomain.  Each attribute name becomes a subdomain of the main `domain`. For instance, with the example above, files in `/media/Media/games` would be available at `games.server.example.com`, assuming `domain` is `server.example.com`.

The value of each attribute should be an absolute path to the directory you want to share.  Nginx's `autoindex` is enabled for these locations, allowing for directory listing in the browser.  `allow all;` is set, meaning there are no additional access controls.

### `local.reverse-proxy.services`

```
Type: attribute set of submodules
Default: {}
Example:
{
  gitea.target = "http://localhost:3001";
}
```

An attribute set defining the services to proxy to. Each attribute name becomes a subdomain of the primary `domain`.

Each service requires a `target` option specifying the backend server to proxy to.  Optionally, `extraConfig` can be used to add additional Nginx configuration for the specific location.

#### `local.reverse-proxy.services.<name>.target`

```
Type: string
Required
```

The backend target URL for the service.  This should be the address and port where the service is running, e.g., `http://localhost:3000` or `http://192.168.1.10:8080`.

#### `local.reverse-proxy.services.<name>.extraConfig`

```
Type: lines string
Default: ""
```

Allows you to specify additional Nginx configuration directives for the service's location block.  This is useful for adding custom headers, rewrite rules, or other advanced configurations. Example usage:

```nix
services = {
  myapp = {
    target = "http://localhost:4000";
    extraConfig = ''
      add_header X-Custom-Header "My Value";
    '';
  };
};
```

This will add the `X-Custom-Header` header to all responses from the `myapp` service.

## Details

This module configures Nginx to act as a reverse proxy. It generates self-signed certificates or uses Let's Encrypt for HTTPS encryption and sets up virtual hosts for the configured services and shared folders. It also includes recommended Nginx settings for proxying, TLS, optimization, and gzip compression.

The module sets up websocket support for modern applications, adding headers to upgrade connections.

A nix command `onix-local-cert` is generated to create the openssl self-signed certificate that will be used.

