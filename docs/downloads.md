# Downloads Module

This Nix module provides options for configuring download-related services, including a base download directory, qBittorrent, and Pinchflat (a YouTube downloader). It allows enabling these services, setting their ports, opening firewall ports, and configuring subpaths for reverse proxies.

## Options

### `local.downloads.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables or disables the download services module.  When enabled, the module will configure the download directory and enable other sub-services based on their respective `enable` options.  Disable this if you don't want any of the download services to be managed by this module.

### `local.downloads.downloadDir`

*   **Type:** `types.str`
*   **Default:** `"${config.local.media.mediaDir}/downloads"`
*   **Example:** `"/mnt/storage/downloads"`
*   **Description:** The base directory where downloads will be stored. This directory serves as the parent directory for downloads managed by qBittorrent, Pinchflat, or other download-related services.  It is crucial for organizing downloaded content and ensuring services have a consistent location to save files. The default value places it within the media directory defined elsewhere in the configuration, creating a logical grouping of media-related data.

### `local.downloads.qbittorrent.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables or disables the qBittorrent BitTorrent client.  When enabled, the module will configure and start the qBittorrent service, allowing you to manage torrent downloads through its web interface.

### `local.downloads.qbittorrent.port`

*   **Type:** `types.port`
*   **Default:** `8080`
*   **Description:** The port number for the qBittorrent web interface.  This port is used to access the qBittorrent web UI through a web browser, allowing you to add, manage, and monitor torrent downloads.  Ensure that this port does not conflict with other services running on your system.

### `local.downloads.qbittorrent.openFirewall`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**  Determines whether to open the firewall ports for qBittorrent.  If set to `true`, the necessary firewall rules will be created to allow incoming connections for qBittorrent, enabling peers to connect and improving download speeds.  Consider the security implications before enabling this option.

### `local.downloads.qbittorrent.subPath`

*   **Type:** `types.str`
*   **Default:** `""`
*   **Example:** `"/qbittorrent"`
*   **Description:**  The subpath for accessing qBittorrent through a reverse proxy.  This option allows you to host qBittorrent behind a reverse proxy like Nginx or Apache, making it accessible under a specific URL path.  For example, setting this to `/qbittorrent` would make qBittorrent accessible at `https://yourdomain.com/qbittorrent`.  Leave it empty if you are not using a reverse proxy or want to access qBittorrent at the root of your domain.

### `local.downloads.pinchflat.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables or disables the Pinchflat YouTube downloader. When enabled, the module configures and starts the Pinchflat service, enabling you to download videos from YouTube through its web interface.

### `local.downloads.pinchflat.port`

*   **Type:** `types.port`
*   **Default:** `8945`
*   **Description:** The port number for the Pinchflat web interface. This port is used to access the Pinchflat web UI through a web browser, allowing you to paste YouTube links and download content.  Ensure this port does not conflict with other services.

### `local.downloads.pinchflat.openFirewall`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**  Determines whether to open the firewall port for Pinchflat.  If set to `true`, the necessary firewall rule will be created to allow incoming connections to the Pinchflat service, making it accessible from outside your local network (if behind a reverse proxy).  Consider the security implications of opening ports to the internet before enabling this option.

