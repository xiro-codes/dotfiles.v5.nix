# port-check

This Nix module is designed to detect and report port conflicts among various services configured within a NixOS system. It aggregates port configurations from different modules (like dashboard, gitea, jellyfin etc.) and checks if any two or more services are trying to use the same port. If conflicts are found, it raises an assertion error, preventing the system from being built until the conflicts are resolved. This helps ensure smooth operation of services and avoids unexpected behavior due to port collisions.

## Options

This module does not directly expose any configurable options under `config.options`. Instead, it relies on the configurations defined within other modules referenced through `config.local`. It extracts port information based on the `enable` flags and associated `port` attributes defined across several submodules, as shown in the configuration code.

The following ports are considered and checked for conflicts, based on whether the related service is enabled:

### Dashboard
*   **`local.dashboard.enable`**: (Type: Boolean, Default: `false`) - Enables the dashboard. When enabled, the dashboard's port is included in the conflict check.
*   **`local.dashboard.port`**: (Type: Integer, Default: `3000`) - The port on which the dashboard service listens.

### Docs
*   **`local.docs.enable`**: (Type: Boolean, Default: `false`) - Enables the documentation service. When enabled, the documentation service's port is included in the conflict check.
*   **`local.docs.port`**: (Type: Integer, Default: `3088`) - The port on which the documentation service listens.

### Gitea
*   **`local.gitea.enable`**: (Type: Boolean, Default: `false`) - Enables the Gitea service. When enabled, both the web port and SSH port are included in the conflict check.
*   **`local.gitea.port`**: (Type: Integer, Default: `3001`) - The port on which the Gitea web interface listens.
*   **`local.gitea.sshPort`**: (Type: Integer, Default: `2222`) - The port on which the Gitea SSH service listens.

### File Browser
*   **`local.file-browser.enable`**: (Type: Boolean, Default: `false`) - Enables the file browser service. When enabled, the file browser's port is included in the conflict check.
*   **`local.file-browser.port`**: (Type: Integer, Default: `8999`) - The port on which the file browser service listens.

### Jellyfin
*   **`local.media.jellyfin.enable`**: (Type: Boolean, Default: `false`) - Enables the Jellyfin media server. When enabled, Jellyfin's port is included in the conflict check.
*   **`local.media.jellyfin.port`**: (Type: Integer, Default: `8096`) - The port on which the Jellyfin server listens.

### Plex
*   **`local.media.plex.enable`**: (Type: Boolean, Default: `false`) - Enables the Plex media server. When enabled, Plex's port is included in the conflict check.
*   **`local.media.plex.port`**: (Type: Integer, Default: `32400`) - The port on which the Plex server listens.

### ErsatzTV
*   **`local.media.ersatztv.enable`**: (Type: Boolean, Default: `false`) - Enables the ErsatzTV service.  When enabled, ErsatzTV's port is included in the conflict check.
*   **`local.media.ersatztv.port`**: (Type: Integer, Default: `8409`) - The port on which the ErsatzTV service listens.

### Komga
*   **`local.media.komga.enable`**: (Type: Boolean, Default: `false`) - Enables the Komga service. When enabled, Komga's port is included in the conflict check.
*   **`local.media.komga.port`**: (Type: Integer, Default: `8092`) - The port on which the Komga service listens.

### Audiobookshelf
*   **`local.media.audiobookshelf.enable`**: (Type: Boolean, Default: `false`) - Enables the Audiobookshelf service. When enabled, Audiobookshelf's port is included in the conflict check.
*   **`local.media.audiobookshelf.port`**: (Type: Integer, Default: `13378`) - The port on which the Audiobookshelf service listens.

### Qbittorrent
*   **`local.downloads.qbittorrent.enable`**: (Type: Boolean, Default: `false`) - Enables the Qbittorrent service. When enabled, Qbittorrent's port is included in the conflict check.
*   **`local.downloads.qbittorrent.port`**: (Type: Integer, Default: `8080`) - The port on which the Qbittorrent web interface listens.

### Pinchflat
*   **`local.downloads.pinchflat.enable`**: (Type: Boolean, Default: `false`) - Enables the Pinchflat service. When enabled, Pinchflat's port is included in the conflict check.
*   **`local.downloads.pinchflat.port`**: (Type: Integer, Default: `8945`) - The port on which the Pinchflat service listens.

### Cache Server
*   **`local.cache-server.enable`**: (Type: Boolean, Default: `false`) - Enables the cache server. When enabled, the cache server's port is included in the conflict check.
*   **`local.cache-server.port`**: (Type: Integer, Default: `8080`) - The port on which the cache server listens.

### PiHole
*   **`local.pihole.enable`**: (Type: Boolean, Default: `false`) - Enables the PiHole service. When enabled, both DNS (port 53) and Web (port 8053) ports are included in the conflict check. Note: These ports are hardcoded.

### Reverse Proxy
*   **`local.reverse-proxy.enable`**: (Type: Boolean, Default: `false`) - Enables the reverse proxy. When enabled, both HTTP (port 80) and HTTPS (port 443) ports are included in the conflict check. Note: These ports are hardcoded.

## Assertions

*   The module asserts that `conflicts == []`. If this assertion fails, it means that port conflicts were detected, and the NixOS build will be aborted.
    *   The error message will be in the form: `"Port conflicts detected:\nPort <port_number> is used by multiple services: <service1>, <service2>, ...\n..."`.
