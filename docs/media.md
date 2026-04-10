# Media

This Nix module provides a convenient way to manage and deploy a stack of media server applications, including Jellyfin, Plex, ErsatzTV, Komga, and Audiobookshelf. It allows you to easily enable these services and configure their ports and firewall settings. It primarily defines options under the `local.media` namespace.

## Options

Here's a breakdown of the configurable options within the `local.media` module:

### `local.media.enable`

- **Type:** Boolean
- **Default:** `false`
- **Description:**  Enables the entire media server stack.  This is the master switch; setting it to `true` allows the individual media services (Jellyfin, Plex, etc.) to be enabled.

### `local.media.mediaDir`

- **Type:** String
- **Default:** `/media/Media`
- **Example:** `/mnt/storage/media`
- **Description:**  Specifies the base directory where your media files are stored.  This path isn't directly used in this module, but it's intended to be a central location for you to manage your media, which you would then configure for the individual media services.

### `local.media.jellyfin.enable`

- **Type:** Boolean
- **Default:** `false`
- **Description:** Enables the Jellyfin media server. Jellyfin organizes, manages, and shares your digital media files.

### `local.media.jellyfin.port`

- **Type:** Port (Integer between 1 and 65535)
- **Default:** `8096`
- **Description:** The HTTP port that Jellyfin will listen on. This is the port you'll use to access the Jellyfin web interface.

### `local.media.jellyfin.openFirewall`

- **Type:** Boolean
- **Default:** `false`
- **Description:**  Determines whether to automatically open the firewall port for Jellyfin.  Setting this to `true` will allow external access to your Jellyfin server if your firewall is enabled.

### `local.media.plex.enable`

- **Type:** Boolean
- **Default:** `false`
- **Description:**  Enables the Plex Media Server. Plex organizes your video, music, and photo collections and streams them to all of your screens.

### `local.media.plex.port`

- **Type:** Port (Integer between 1 and 65535)
- **Default:** `32400`
- **Description:**  The HTTP port that Plex will listen on.  This is the port you'll use to access the Plex web interface.

### `local.media.plex.openFirewall`

- **Type:** Boolean
- **Default:** `false`
- **Description:** Determines whether to automatically open the firewall port for Plex. Setting this to `true` will allow external access to your Plex server if your firewall is enabled.

### `local.media.ersatztv.enable`

- **Type:** Boolean
- **Default:** `false`
- **Description:**  Enables the ErsatzTV streaming service.  ErsatzTV allows you to create live TV channels from your existing media library.

### `local.media.ersatztv.port`

- **Type:** Port (Integer between 1 and 65535)
- **Default:** `8409`
- **Description:** The HTTP port that ErsatzTV will listen on. This is the port you'll use to access the ErsatzTV web interface.

### `local.media.ersatztv.openFirewall`

- **Type:** Boolean
- **Default:** `false`
- **Description:** Determines whether to automatically open the firewall port for ErsatzTV. Setting this to `true` will allow external access to your ErsatzTV server if your firewall is enabled.

### `local.media.komga.enable`

- **Type:** Boolean
- **Default:** `false`
- **Description:** Enables the Komga comic/manga server. Komga organizes and serves your digital comics and manga.

### `local.media.komga.port`

- **Type:** Port (Integer between 1 and 65535)
- **Default:** `8092`
- **Description:**  The HTTP port that Komga will listen on.  This is the port you'll use to access the Komga web interface.

### `local.media.komga.openFirewall`

- **Type:** Boolean
- **Default:** `false`
- **Description:**  Determines whether to automatically open the firewall port for Komga.  Setting this to `true` will allow external access to your Komga server if your firewall is enabled.

### `local.media.audiobookshelf.enable`

- **Type:** Boolean
- **Default:** `false`
- **Description:**  Enables the Audiobookshelf audiobook server. Audiobookshelf is a self-hosted audiobook server for streaming and managing your audiobooks.

### `local.media.audiobookshelf.port`

- **Type:** Port (Integer between 1 and 65535)
- **Default:** `13378`
- **Description:** The HTTP port that Audiobookshelf will listen on. This is the port you'll use to access the Audiobookshelf web interface.

### `local.media.audiobookshelf.openFirewall`

- **Type:** Boolean
- **Default:** `false`
- **Description:** Determines whether to automatically open the firewall port for Audiobookshelf. Setting this to `true` will allow external access to your Audiobookshelf server if your firewall is enabled.

