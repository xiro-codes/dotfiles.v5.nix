# pihole

This module provides a NixOS configuration for deploying Pi-hole, a network-wide ad blocker, using OCI containers. It sets up the necessary directories, configures the container with appropriate settings, and opens firewall ports for DNS traffic.

## Options

### `local.pihole.enable`

Type: boolean

Default: `false`

Description: Enables or disables the Pi-hole DNS service. When enabled, this module configures a container to run Pi-hole and sets up necessary system configurations like firewall rules.

### `local.pihole.dataDir`

Type: string

Default: `"/var/lib/pihole"`

Description: The directory to store Pi-hole's configuration and data. This directory is mounted as a volume into the Pi-hole container, ensuring data persistence across container restarts. Make sure this directory exists and is writeable.

### `local.pihole.adminPassword`

Type: string

Default: `"admin"`

Description: The admin password for accessing the Pi-hole web UI.  It's *highly recommended* to change this to a strong, unique password for security reasons. This password will be set as the `WEBPASSWORD` environment variable inside the container.

## Implementation Details

When `local.pihole.enable` is set to `true`, the following actions are taken:

1.  **Data Directory Creation:**
    *   Systemd tmpfiles rules are created to ensure that the specified `dataDir` and its subdirectory `dnsmasq.d` exist with appropriate permissions (0777, owned by root).  The `dnsmasq.d` directory is specifically used for custom dnsmasq configurations.

2.  **OCI Container Configuration:**
    *   An OCI container named `pihole` is defined using `virtualisation.oci-containers.containers.pihole`.
    *   **Image:** The `pihole/pihole:latest` Docker image is used, ensuring the latest version of Pi-hole is deployed.
    *   **Ports:** The following ports are exposed:
        *   `53:53/tcp`: Standard DNS over TCP.
        *   `53:53/udp`: Standard DNS over UDP.
        *   `8053:80/tcp`: The Pi-hole web UI is exposed on port 8053 on the host, mapped to port 80 inside the container. Shifting it to `8053` avoids conflicts with other services (like Nginx) that may also want to use port 80.
    *   **Volumes:** The following volumes are mounted:
        *   `${cfg.dataDir}:/etc/pihole`:  Mounts the `dataDir` on the host to `/etc/pihole` inside the container, storing Pi-hole's core configuration (e.g., adlists, whitelist, blacklist, DHCP settings).
        *   `${cfg.dataDir}/dnsmasq.d:/etc/dnsmasq.d`: Mounts the `dnsmasq.d` subdirectory to `/etc/dnsmasq.d` inside the container, allowing you to add custom `dnsmasq` configurations by dropping `.conf` files into this directory.
    *   **Environment Variables:** Crucial environment variables are set:
        *   `TZ = config.time.timeZone or "UTC"`: Sets the timezone of the Pi-hole container. If `config.time.timeZone` is defined in your NixOS configuration, it's used; otherwise, defaults to UTC.
        *   `WEBPASSWORD = cfg.adminPassword`: Sets the admin password for the Pi-hole web UI.
        *   `FTLCONF_dns_listeningMode = "ALL"`:  This is a critical option. It configures Pi-hole to listen on all interfaces (both IPv4 and IPv6). If it's not explicitly set, Pi-hole might only listen on a single interface (e.g., only IPv4), which can lead to DNS resolution failures.
        *   `PIHOLE_DNS_ = "1.1.1.1;1.0.0.1"`: Sets the upstream DNS servers that Pi-hole will use to resolve queries after filtering. In this case, it uses Cloudflare's public DNS servers.  You can customize this list with your preferred DNS providers, separating multiple addresses with semicolons.
        *   `IPv6 = "False"`: This option explicitly disables IPv6 within pihole, this may be required to ensure pihole functions as expected when IPv6 is not properly configured.
    *   `autoStart = true`: Configures the container to start automatically on system boot.

3.  **Firewall Configuration:**
    *   The NixOS firewall is configured to allow TCP and UDP traffic on port 53, enabling external devices on the network to query the Pi-hole DNS server.

4.  **Systemd-resolved Mitigation (Commented Out):**
    *   The original code included attempts to disable `systemd-resolved` from using port 53. This is commented out because disabling `systemd-resolved` might impact other services or require careful network configuration.  If you experience conflicts with `systemd-resolved` using port 53, uncomment and adapt these lines, or preferrably, configure `systemd-resolved` to use a different port for its stub listener.  The code shows the configuration to disable the `DNSStubListener` completely.

