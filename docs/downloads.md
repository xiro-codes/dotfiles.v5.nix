# downloads

This Nix module provides configuration options for managing download services, specifically qBittorrent and Pinchflat (a YouTube downloader). It allows you to easily enable, configure, and manage these services within your NixOS system. This module also handles firewall configuration and directory setup.

## Options

### `local.downloads.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables or disables the download services module.  This is the master switch; if disabled, none of the other options in this module will have any effect.

### `local.downloads.downloadDir`

*   **Type:** `String`
*   **Default:** `"${config.local.media.mediaDir}/downloads"`
*   **Example:** `"/mnt/storage/downloads"`
*   **Description:**  The base directory where downloads will be stored. It defaults to a subdirectory named `downloads` inside the `mediaDir` specified in `local.media`. This provides a central location to manage all downloaded content.  It's important that this directory exists and has appropriate permissions for the download services.

### `local.downloads.qbittorrent`

Configuration options for the qBittorrent BitTorrent client.

#### `local.downloads.qbittorrent.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables or disables the qBittorrent service.

#### `local.downloads.qbittorrent.port`

*   **Type:** `Port`
*   **Default:** `8080`
*   **Description:** The port number for the qBittorrent web interface. This is the port you will use to access qBittorrent in your browser.

#### `local.downloads.qbittorrent.openFirewall`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Opens the firewall port for qBittorrent, allowing external access to the web interface. Setting this to `true` is necessary if you want to access qBittorrent from outside your local network.

#### `local.downloads.qbittorrent.subPath`

*   **Type:** `String`
*   **Default:** `""`
*   **Example:** `"/qbittorrent"`
*   **Description:** The subpath for the qBittorrent web interface when accessed through a reverse proxy.  This allows you to serve qBittorrent under a specific path on your domain (e.g., `yourdomain.com/qbittorrent`).  Leave empty for no subpath.

### `local.downloads.pinchflat`

Configuration options for the Pinchflat YouTube downloader.

#### `local.downloads.pinchflat.enable`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Enables or disables the Pinchflat service.

#### `local.downloads.pinchflat.port`

*   **Type:** `Port`
*   **Default:** `8945`
*   **Description:** The port number for the Pinchflat web interface.  This is the port you will use to access Pinchflat in your browser.

#### `local.downloads.pinchflat.openFirewall`

*   **Type:** `Boolean`
*   **Default:** `false`
*   **Description:** Opens the firewall port for Pinchflat, allowing external access to the web interface.  Setting this to `true` is necessary if you want to access Pinchflat from outside your local network.

