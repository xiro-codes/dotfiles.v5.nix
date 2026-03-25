# media

This Nix module provides a convenient way to manage and deploy a media server stack, including popular services like Jellyfin, Plex, ErsatzTV, Komga, and Audiobookshelf. It allows you to easily enable these services, configure their ports, and manage firewall rules.

## Options

This module defines the following options under the `local.media` scope:

### `local.media.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the media server stack module. This is the main switch to activate the configuration of all media-related services defined in this module.  Setting this to `true` will enable the subsequent configuration options for the individual services (Jellyfin, Plex, etc.).

### `local.media.mediaDir`

*   **Type:** `string`
*   **Default:** `"/media/Media"`
*   **Example:** `"/mnt/storage/media"`
*   **Description:**  Specifies the base directory for your media files.  This path is intended to be the root directory where all your movies, TV shows, music, books, comics, and other media content are stored.  While this module doesn't directly use this value in service configurations (the individual services must be configured to access it), this option serves as a central point of reference for the location of your media.  Consider using a symbolic link from the default location to your actual media directory for clarity and ease of management.

### `local.media.jellyfin.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Jellyfin media server. When set to `true`, the `services.jellyfin` service is enabled in NixOS.

### `local.media.jellyfin.port`

*   **Type:** `port` (integer between 1 and 65535)
*   **Default:** `8096`
*   **Description:** Specifies the HTTP port for the Jellyfin web interface. This is the port you will use to access Jellyfin in your web browser.

### `local.media.jellyfin.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**  Opens the firewall port for Jellyfin.  If set to `true`, the NixOS firewall will be configured to allow incoming connections to the specified Jellyfin port, making the server accessible from other devices on your network or the internet (depending on your firewall configuration).  Ensure you understand the security implications of opening ports to the internet before enabling this option.

### `local.media.plex.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Plex Media Server. When set to `true`, the `services.plex` service is enabled in NixOS.

### `local.media.plex.port`

*   **Type:** `port` (integer between 1 and 65535)
*   **Default:** `32400`
*   **Description:** Specifies the HTTP port for the Plex web interface. This is the port you will use to access Plex in your web browser.

### `local.media.plex.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Opens the firewall port for Plex. If set to `true`, the NixOS firewall will be configured to allow incoming connections to the specified Plex port.

### `local.media.ersatztv.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the ErsatzTV streaming service. When set to `true`, the `services.ersatztv` service is enabled in NixOS.

### `local.media.ersatztv.port`

*   **Type:** `port` (integer between 1 and 65535)
*   **Default:** `8409`
*   **Description:** Specifies the HTTP port for the ErsatzTV web interface.

### `local.media.ersatztv.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Opens the firewall port for ErsatzTV. If set to `true`, the NixOS firewall will be configured to allow incoming connections to the specified ErsatzTV port.

### `local.media.komga.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Komga comic/manga server. When set to `true`, the `services.komga` service is enabled in NixOS.

### `local.media.komga.port`

*   **Type:** `port` (integer between 1 and 65535)
*   **Default:** `8092`
*   **Description:** Specifies the HTTP port for Komga.

### `local.media.komga.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Opens the firewall port for Komga. If set to `true`, the NixOS firewall will be configured to allow incoming connections to the specified Komga port.

### `local.media.audiobookshelf.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Audiobookshelf audiobook server. When set to `true`, the `services.audiobookshelf` service is enabled in NixOS.

### `local.media.audiobookshelf.port`

*   **Type:** `port` (integer between 1 and 65535)
*   **Default:** `13378`
*   **Description:** Specifies the HTTP port for Audiobookshelf.

### `local.media.audiobookshelf.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Opens the firewall port for Audiobookshelf. If set to `true`, the NixOS firewall will be configured to allow incoming connections to the specified Audiobookshelf port.

