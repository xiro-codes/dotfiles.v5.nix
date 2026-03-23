# port-conflict-checker

This Nix module checks for port conflicts among various services configured in the `local` configuration. It defines a list of ports used by different services and asserts that there are no overlaps, providing an informative error message if conflicts are found. This helps ensure that services do not interfere with each other due to port collisions.

## Options

This module depends on the `local` configuration passed in through `config.local`.
It dynamically checks for port conflicts based on whether services are enabled and what ports are configured for them.

There are no explicit options defined in this module, however the following services are considered when checking for port conflicts via `config.local.*`:

*   **`config.local.dashboard.enable`** (Boolean):  Enables or disables the dashboard service.  If enabled, the `config.local.dashboard.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.dashboard.port`** (Integer): The port number used by the dashboard service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.docs.enable`** (Boolean): Enables or disables the documentation service. If enabled, the `config.local.docs.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.docs.port`** (Integer): The port number used by the documentation service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.gitea.enable`** (Boolean): Enables or disables the Gitea service. If enabled, the `config.local.gitea.port` and `config.local.gitea.sshPort` options are used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.gitea.port`** (Integer): The port number used by the Gitea web interface.
    *   Default: N/A (depends on user configuration)

*   **`config.local.gitea.sshPort`** (Integer): The port number used by the Gitea SSH service.
    *   Default: `2222`

*   **`config.local.file-browser.enable`** (Boolean): Enables or disables the file browser service. If enabled, the `config.local.file-browser.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.file-browser.port`** (Integer): The port number used by the file browser service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.jellyfin.enable`** (Boolean): Enables or disables the Jellyfin media server. If enabled, the `config.local.media.jellyfin.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.jellyfin.port`** (Integer): The port number used by the Jellyfin media server.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.plex.enable`** (Boolean): Enables or disables the Plex media server. If enabled, the `config.local.media.plex.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.plex.port`** (Integer): The port number used by the Plex media server.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.ersatztv.enable`** (Boolean): Enables or disables the ErsatzTV service. If enabled, the `config.local.media.ersatztv.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.ersatztv.port`** (Integer): The port number used by the ErsatzTV service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.komga.enable`** (Boolean): Enables or disables the Komga service. If enabled, the `config.local.media.komga.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.komga.port`** (Integer): The port number used by the Komga service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.audiobookshelf.enable`** (Boolean): Enables or disables the Audiobookshelf service. If enabled, the `config.local.media.audiobookshelf.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.media.audiobookshelf.port`** (Integer): The port number used by the Audiobookshelf service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.downloads.qbittorrent.enable`** (Boolean): Enables or disables the qBittorrent service. If enabled, the `config.local.downloads.qbittorrent.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.downloads.qbittorrent.port`** (Integer): The port number used by the qBittorrent service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.downloads.pinchflat.enable`** (Boolean): Enables or disables the Pinchflat service. If enabled, the `config.local.downloads.pinchflat.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.downloads.pinchflat.port`** (Integer): The port number used by the Pinchflat service.
    *   Default: N/A (depends on user configuration)

*   **`config.local.harmonia-cache.enable`** (Boolean): Enables or disables the Harmonia Cache service. If enabled, the `config.local.harmonia-cache.port` option is used for port conflict detection.
    *   Default: N/A (depends on user configuration)

*   **`config.local.harmonia-cache.port`** (Integer): The port number used by the Harmonia Cache server.
    *   Default: N/A (depends on user configuration)

*   **`config.local.pihole.enable`** (Boolean): Enables or disables the Pi-hole service. If enabled, ports `53` (DNS) and `8053` (Web) are used for port conflict detection.  These are hardcoded in the module.
    *   Default: N/A (depends on user configuration)

*   **`config.local.reverse-proxy.enable`** (Boolean): Enables or disables the reverse proxy. If enabled, ports `80` (HTTP) and `443` (HTTPS) are used for port conflict detection. These are hardcoded in the module.
    *   Default: N/A (depends on user configuration)

## Assertions

*   **Port Conflict Check**: The module asserts that there are no port conflicts among the configured services. If conflicts are detected, an error message is generated, listing the conflicting ports and the services using them.

    *   `assertion = conflicts == [];`
    *   `message = "Port conflicts detected:\n${concatStringsSep "\n" conflicts}";`

