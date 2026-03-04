# dashboard

This Nix module configures a homepage dashboard, providing a central point for accessing various services running on your server. It allows you to define which services to display, their icons, and links, making it easy to navigate your self-hosted applications. The module supports reverse proxy configurations, allowing for clean and consistent URLs for your services. It also integrates with the system firewall to optionally open the dashboard port. Resource monitoring is also available as a widget.

## Options

Here's a detailed breakdown of the available configuration options:

### `local.dashboard.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables or disables the homepage dashboard. When enabled, the module configures and starts the `homepage-dashboard` service.

### `local.dashboard.port`

*   **Type:** `Port` (Integer between 1 and 65535)
*   **Default:** `3000`
*   **Description:** Specifies the port number on which the dashboard will listen for incoming connections.  This is the port you'll use to access the dashboard directly if not using a reverse proxy.

### `local.dashboard.openFirewall`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:**  Determines whether to automatically open the configured `port` in the system firewall. Setting this to `true` allows external access to the dashboard, assuming your firewall is enabled.

### `local.dashboard.allowedHosts`

*   **Type:** `List of Strings`
*   **Default:** Automatically generated list containing the hostname, IP address, and `.local` address of the system.
*   **Example:** `[ "onix.local" "192.168.1.100" ]`
*   **Description:** A list of allowed hostnames for accessing the dashboard, primarily used in reverse proxy scenarios.  This setting prevents unauthorized access by ensuring the dashboard only responds to requests originating from these specified hosts.  The default value provides reasonable local network access.  It is important to configure this properly when using a reverse proxy to avoid security vulnerabilities.

## Configuration Details

When `local.dashboard.enable` is set to `true`, the following configurations are applied:

*   **`services.homepage-dashboard`**: This section configures the underlying `homepage-dashboard` service.
    *   **`enable = true`**: Starts the `homepage-dashboard` service.
    *   **`listenPort = cfg.port`**:  Sets the port the service listens on to the configured `local.dashboard.port`.
    *   **`allowedHosts = lib.concatStringsSep "," cfg.allowedHosts`**:  Concatenates the list of allowed hosts into a comma-separated string, passed to the `homepage-dashboard` service.
    *   **`settings`**:  Contains dashboard specific settings.
        *   **`title = "Home Server Dashboard"`**: Sets the title displayed in the dashboard's header.
        *   **`layout`**:  Defines the layout of the dashboard, creating named sections (Services, Media, Downloads) with a row-based style and three columns.
    *   **`services`**:  Dynamically generates the list of services displayed on the dashboard, based on which services are enabled in other parts of the Nix configuration.

        *   Uses `lib.optional` and `config.local.*.enable` checks to include or exclude specific services.
        *   Uses `urlHelpers.buildServiceUrl` to correctly build URLs for the services based on whether a reverse proxy is used.
        *   Each service definition includes:
            *   `icon`: The filename of the icon to display (e.g., "mdi-book-information", "gitea.png").
            *   `href`:  The URL to access the service.
            *   `description`: A short description of the service.
    *   **`widgets`**: Configures widgets to display on the dashboard.
        *    A resource widget is enabled by default to monitor CPU, memory, and disk usage on specified mountpoints.

*   **`networking.firewall.allowedTCPPorts`**: If `local.dashboard.openFirewall` is set to `true`, this option opens the dashboard port in the system firewall.

*   **`systemd.services.homepage-dashboard`**:  Conditionally configures the Systemd service for the dashboard, setting environment variables related to allowed hosts (commented out in the provided code, might need adjustments based on the actual `homepage-dashboard` implementation).
