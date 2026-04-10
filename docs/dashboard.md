# dashboard

This Nix module configures and enables a homepage dashboard. It provides options to customize the dashboard's port, firewall settings, and allowed hosts. The module also configures the `homepage` service with various settings, services, media links, and widgets.  It is designed to integrate with other modules like `reverse-proxy`, `docs`, `gitea`, `pihole`, `ersatztv`, `jellyfin`, `plex`, `komga`, `audiobookshelf`, `pinchflat`, and `qbittorrent` by dynamically generating links based on their enabled status and configured ports/domains.  It assumes that the `homepage` service is available.

## Options

### `local.dashboard.enable`

Type: `types.bool`

Default: `false`

Description: Enables the homepage dashboard.  Setting this to `true` will configure and start the `homepage-dashboard` service.

### `local.dashboard.port`

Type: `types.port`

Default: `3000`

Description: Port to run the dashboard on. This specifies the TCP port that the `homepage-dashboard` service will listen on.

### `local.dashboard.openFirewall`

Type: `types.bool`

Default: `false`

Description: Open firewall port for the dashboard. When set to `true`, this option will configure the firewall to allow TCP traffic on the port specified by `local.dashboard.port`.

### `local.dashboard.allowedHosts`

Type: `types.listOf types.str`

Default: _Dynamically generated based on hostname, IP, and .local address._

Example: `[ "onix.local" "192.168.1.100" ]`

Description: List of allowed hostnames for accessing the dashboard (for reverse proxy). This option is crucial for security when using a reverse proxy.  It allows you to specify a list of hostnames that are permitted to access the dashboard.  The default value is automatically generated to include the system's hostname, IP address, and a `.local` address, providing a reasonable starting point for most local setups.  If you are accessing the dashboard through a reverse proxy with a specific domain name, you *must* include that domain in this list to prevent access restrictions.

## Configuration Details

When `local.dashboard.enable` is set to `true`, the following configurations are applied:

*   **`services.homepage-dashboard`**: Enables and configures the `homepage-dashboard` service. This includes:
    *   `enable`: `true` (enables the service)
    *   `listenPort`: The value of `cfg.port`.
    *   `allowedHosts`: A comma-separated string of hostnames from `cfg.allowedHosts`.
    *   `settings`: Configuration options for the dashboard itself, including:
        *   `title`: "Home Server Dashboard"
        *   `theme`: "dark"
        *   `color`: "emerald"
        *   `layout`: Defines the layout of services, shared folders, media, and downloads sections using a row style with 3 columns each.
        *   `services`: Dynamically generates a list of services based on whether associated modules (`docs`, `gitea`, `pihole`, `ersatztv`) are enabled. Each service entry includes an icon, `href` (generated either directly or using a reverse proxy if enabled), and a description. The service URLs are dynamically generated based on the `local.reverse-proxy.enable` and `local.reverse-proxy.domain` settings.  If a reverse proxy is used, URLs are of the form `http://${name}.${domain}`; otherwise, they are of the form `http://${domain}:${port}`.
        *   `Shared Folders`: Uses shared folder configurations to generate displayable links with associated folder and description.
        *   `media`: Populates the services with `jellyfin`, `plex`, `komga`, and `audiobookshelf`.
        *   `downloads`: Populates the services with `pinchflat` and `qbittorrent`.
    *   `widgets`: Configures widgets for search (using DuckDuckGo) and displaying date/time and system resources (CPU, memory, and disk usage for `/`, `/media/Media`, and `/media/Backups`).

*   **`networking.firewall.allowedTCPPorts`**: If `cfg.openFirewall` is `true`, adds `cfg.port` to the list of allowed TCP ports in the firewall.

*   **`systemd.services.homepage-dashboard`**: Configures systemd service environment variables related to allowed hosts. *Note: These are commented out in the code, meaning they are not currently being set.*

