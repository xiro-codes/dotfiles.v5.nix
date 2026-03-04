# reverse-proxy

This Nix module configures a reverse proxy using Nginx, enabling automatic HTTPS with either Let's Encrypt or self-signed certificates.  It allows you to easily proxy requests to different backend services based on the subdomain and provides options for configuring shared folders served via HTTP.

## Options

Here's a detailed breakdown of the available configuration options:

- **`local.reverse-proxy.enable`**
  - **Type:** `boolean`
  - **Default:** `false`
  - **Description:** Enables or disables the reverse proxy functionality. Setting this to `true` activates the Nginx configuration and related settings.

- **`local.reverse-proxy.acmeEmail`**
  - **Type:** `string`
  - **Default:** `""` (empty string)
  - **Example:** `"admin@example.com"`
  - **Description:** The email address used for ACME/Let's Encrypt certificate registration. This is required when using Let's Encrypt to obtain certificates for your domain.  It's crucial for renewal notifications and handling issues with your certificates.

- **`local.reverse-proxy.useACME`**
  - **Type:** `boolean`
  - **Default:** `false`
  - **Description:** Determines whether to use Let's Encrypt for automatic HTTPS certificate management. When set to `true`, the module attempts to obtain and renew certificates using the ACME protocol.  Requires a publicly accessible domain name and a valid `acmeEmail`.  If set to `false`, a self-signed certificate is generated and used.  Using ACME provides trusted certificates by default, whereas the self-signed option will need to be manually trusted by the user if they do not configure local certificate trust.

- **`local.reverse-proxy.domain`**
  - **Type:** `string`
  - **Default:** `"localhost"`
  - **Example:** `"server.example.com"`
  - **Description:** The primary domain name for the reverse proxy. This domain will be used for the main service and as the base for subdomain-based services. For example, if the domain is `example.com` and you configure a service named `gitea`, it will be accessible at `gitea.example.com`.

- **`local.reverse-proxy.openFirewall`**
  - **Type:** `boolean`
  - **Default:** `true`
  - **Description:**  Controls whether to automatically open firewall ports 80 (HTTP) and 443 (HTTPS) on the system.  Setting this to `true` simplifies initial setup by allowing external access to the reverse proxy. If set to `false`, you'll need to manually configure the firewall rules.

- **`local.reverse-proxy.sharedFolder`**
  - **Type:** `null or path`
  - **Default:** `null`
  - **Description:** Specifies a path on the disk to serve as static files.  If set to a valid path, a virtual host `files.onix.home` will be created, serving the content of the specified directory. This provides a convenient way to share files via HTTP/HTTPS.  Autoindexing will be enabled, listing the directory content in the browser.

- **`local.reverse-proxy.services`**
  - **Type:** `attribute set of submodules`
  - **Default:** `{}` (empty attribute set)
  - **Example:**
    ```nix
    {
      gitea.target = "http://localhost:3001";
    }
    ```
  - **Description:** Defines the services to be proxied by Nginx.  Each attribute in this set represents a service, where the attribute name becomes the subdomain for the service (e.g., `gitea` becomes `gitea.yourdomain.com`). Each service definition is a submodule with the following options:

    - **`target`**
      - **Type:** `string`
      - **Description:** The backend URL to which the reverse proxy will forward requests. This is typically the address and port where the service is running (e.g., `http://localhost:3000` or `http://192.168.1.10:8080`).

    - **`extraConfig`**
      - **Type:** `lines`
      - **Default:** `""` (empty string)
      - **Description:** Allows you to add custom Nginx configuration directives specific to this service's location block. This is useful for fine-tuning proxy settings, adding custom headers, or implementing specific security measures. Multiple lines are supported.
