# port-conflict-checker

This Nix module checks for port conflicts among various services configured in the `local` configuration. It gathers port information from different services like Dashboard, Gitea, Jellyfin, etc., and verifies that no two services are using the same port. If conflicts are found, it will raise an assertion error during the Nix evaluation, preventing the configuration from being applied.  This helps to ensure a smooth deployment experience and avoids issues caused by services competing for the same port.

## Options

This module does not directly expose any configuration options to the user. Instead, it relies on options defined by *other* modules (such as `dashboard`, `gitea`, `jellyfin`, etc.) under the `config.local` namespace. It then uses those settings to perform its conflict checking logic.

To understand how this module works, you must understand the configuration options of the modules that it checks, such as those listed below.  Where these options are enabled, the checker will verify the ports are not in conflict.

The following services *are* checked for port conflicts:

*   **`config.local.dashboard.enable`** (Boolean): Enables or disables the Dashboard service. Default likely varies based on your configuration.  If enabled, the `config.local.dashboard.port` option is used to determine the port.
*   **`config.local.dashboard.port`** (Integer): The port number for the Dashboard service. Default likely varies based on your configuration.

*   **`config.local.docs.enable`** (Boolean): Enables or disables the Docs service. Default likely varies based on your configuration.  If enabled, the `config.local.docs.port` option is used to determine the port.
*   **`config.local.docs.port`** (Integer): The port number for the Docs service. Default likely varies based on your configuration.

*   **`config.local.gitea.enable`** (Boolean): Enables or disables the Gitea service. Default likely varies based on your configuration.  If enabled, the `config.local.gitea.port` and `config.local.gitea.sshPort` options are used to determine the web and SSH ports, respectively.
*   **`config.local.gitea.port`** (Integer): The port number for the Gitea web interface. Default likely varies based on your configuration.
*   **`config.local.gitea.sshPort`** (Integer): The port number for the Gitea SSH service. Defaults to `2222`.

*   **`config.local.file-browser.enable`** (Boolean): Enables or disables the File Browser service. Default likely varies based on your configuration. If enabled, the `config.local.file-browser.port` option is used to determine the port.
*   **`config.local.file-browser.port`** (Integer): The port number for the File Browser service. Default likely varies based on your configuration.

*   **`config.local.media.jellyfin.enable`** (Boolean): Enables or disables the Jellyfin service. Default likely varies based on your configuration. If enabled, the `config.local.media.jellyfin.port` option is used to determine the port.
*   **`config.local.media.jellyfin.port`** (Integer): The port number for the Jellyfin service. Default likely varies based on your configuration.

*   **`config.local.media.plex.enable`** (Boolean): Enables or disables the Plex service. Default likely varies based on your configuration. If enabled, the `config.local.media.plex.port` option is used to determine the port.
*   **`config.local.media.plex.port`** (Integer): The port number for the Plex service. Default likely varies based on your configuration.

*   **`config.local.media.ersatztv.enable`** (Boolean): Enables or disables the ErsatzTV service. Default likely varies based on your configuration. If enabled, the `config.local.media.ersatztv.port` option is used to determine the port.
*   **`config.local.media.ersatztv.port`** (Integer): The port number for the ErsatzTV service. Default likely varies based on your configuration.

*   **`config.local.media.komga.enable`** (Boolean): Enables or disables the Komga service. Default likely varies based on your configuration. If enabled, the `config.local.media.komga.port` option is used to determine the port.
*   **`config.local.media.komga.port`** (Integer): The port number for the Komga service. Default likely varies based on your configuration.

*   **`config.local.media.audiobookshelf.enable`** (Boolean): Enables or disables the Audiobookshelf service. Default likely varies based on your configuration. If enabled, the `config.local.media.audiobookshelf.port` option is used to determine the port.
*   **`config.local.media.audiobookshelf.port`** (Integer): The port number for the Audiobookshelf service. Default likely varies based on your configuration.

*   **`config.local.downloads.qbittorrent.enable`** (Boolean): Enables or disables the Qbittorrent service. Default likely varies based on your configuration. If enabled, the `config.local.downloads.qbittorrent.port` option is used to determine the port.
*   **`config.local.downloads.qbittorrent.port`** (Integer): The port number for the Qbittorrent service. Default likely varies based on your configuration.

*   **`config.local.downloads.pinchflat.enable`** (Boolean): Enables or disables the Pinchflat service. Default likely varies based on your configuration. If enabled, the `config.local.downloads.pinchflat.port` option is used to determine the port.
*   **`config.local.downloads.pinchflat.port`** (Integer): The port number for the Pinchflat service. Default likely varies based on your configuration.

*   **`config.local.harmonia-cache.enable`** (Boolean): Enables or disables the Harmonia Cache service. Default likely varies based on your configuration. If enabled, the `config.local.harmonia-cache.port` option is used to determine the port.
*   **`config.local.harmonia-cache.port`** (Integer): The port number for the Harmonia Cache service. Default likely varies based on your configuration.

*   **`config.local.pihole.enable`** (Boolean): Enables or disables the PiHole service. Default likely varies based on your configuration. If enabled, the DNS and web ports (53 and 8053 respectively) are checked.

*   **`config.local.reverse-proxy.enable`** (Boolean): Enables or disables the Reverse Proxy service. Default likely varies based on your configuration. If enabled, ports 80 and 443 are checked.

