# dashboard

This Nix module configures a homepage dashboard, providing a central interface to access various services running on your server.  It offers features like service links, resource monitoring widgets, and integration with other modules in your NixOS configuration. The module allows you to enable and configure the dashboard, define allowed hosts for access (especially useful when using a reverse proxy), and open the necessary firewall port.

## Options

Here's a breakdown of the configurable options within the `local.dashboard` namespace:

### `local.dashboard.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables the homepage dashboard. When set to `true`, the module activates the necessary services and configurations to run the dashboard. This is the primary switch to turn the dashboard functionality on or off.

    ```nix
    local.dashboard.enable = true;
    ```

### `local.dashboard.port`

*   **Type:** `types.port` (An integer representing a valid TCP/UDP port number.)
*   **Default:** `3000`
*   **Description:** Specifies the port number on which the dashboard service will listen for incoming connections.  You can change this to avoid conflicts with other services or to use a different port for security reasons.

    ```nix
    local.dashboard.port = 8080; # Example: Change the port to 8080
    ```

### `local.dashboard.openFirewall`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Determines whether the NixOS firewall should be configured to allow TCP traffic on the specified `port`. Setting this to `true` automatically opens the port, making the dashboard accessible from other devices on your network.  It's crucial for making the dashboard accessible, but be mindful of security implications when opening ports.

    ```nix
    local.dashboard.openFirewall = true; # Open the firewall port
    ```

### `local.dashboard.allowedHosts`

*   **Type:** `types.listOf types.str` (A list of strings representing valid hostnames or IP addresses.)
*   **Default:** Automatically generated list of allowed hosts based on the system's hostname, IP address and `.local` address.
*   **Example:** `[ "onix.local" "192.168.1.100" ]`
*   **Description:**  A list of allowed hostnames or IP addresses that are permitted to access the dashboard.  This is particularly important when using a reverse proxy, as it restricts which hosts can be used to access the dashboard.  The default value automatically configures this list based on the system's hostname, IP, and `.local` address, providing a reasonable default for local network access.  You should explicitly define this if you intend to access the dashboard from specific domains or IPs through a reverse proxy.

    ```nix
    local.dashboard.allowedHosts = [ "dashboard.example.com" "192.168.1.50" ];
    ```

## Implementation Details

The module leverages several NixOS features:

*   **`services.homepage-dashboard`:**  This section configures the underlying `homepage` service to listen on the specified port, sets the allowed hosts, and configures the dashboard's settings (title, layout, services, and widgets).  The `services` setting is dynamically generated based on other NixOS modules that are enabled (e.g., Gitea, Jellyfin, Pi-hole).
*   **`networking.firewall.allowedTCPPorts`:** This is only configured when `openFirewall` is enabled. It opens the specified port in the NixOS firewall.
*   **`systemd.services.homepage-dashboard`:** This allows for further configuration of the systemd service that runs the dashboard. The current implementation is intended to allow the `HOMEPAGE_CONFIG_ALLOWED_HOSTS` and `HOMEPAGE_ALLOWED_HOSTS` to be set via environment variables which are useful when running behind a reverse proxy.

## Dependencies

*   **`../lib/url-helpers.nix`:** This file contains functions for constructing URLs and deriving default allowed hosts based on the system configuration.  It simplifies the process of generating service links and setting up access restrictions.  Specifically the `buildServiceUrl` function generates urls for various services. And the `getAllowedHosts` function gathers the hostname, ip address and .local address as allowed hosts.
*   **`config.local.reverse-proxy`:** This configuration is used to determine if a reverse proxy is enabled and to retrieve the domain name, which affects how service URLs are constructed.
*   Other `config.local.*` modules (e.g., `config.local.gitea`, `config.local.media.jellyfin`) for dynamic service configuration. The existence of these modules are checked and used to provide service links to those applications on the dashboard.

## Usage Example

To enable the dashboard, open the firewall, and allow access from a specific domain, you would add the following to your `configuration.nix`:

```nix
{
  imports = [
    ./modules/dashboard.nix
  ];

  local.dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = [ "dashboard.example.com" ];
  };
}
```

