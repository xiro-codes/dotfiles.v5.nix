# gog-downloader

This Nix module provides automated synchronization of your GOG library using `lgogdownloader`. It sets up a systemd timer and service to periodically download or update your GOG games to a specified directory.  It is designed to make it easy to keep your GOG library up to date on a NixOS system.

## Options

Here is a detailed breakdown of the available options within the `local.gog-downloader` namespace:

### `local.gog-downloader.enable`

*   **Type:**  `Boolean`
*   **Default:** `false` (disabled)
*   **Description:** Enables or disables the automated GOG library synchronization service.  Setting this to `true` will configure the systemd timer and service responsible for running `lgogdownloader`.

### `local.gog-downloader.directory`

*   **Type:**  `Path`
*   **Default:** `"/media/Media/games"`
*   **Description:** Specifies the directory where the downloaded GOG games will be stored.  This should be a path that exists and is accessible by the user running the service (usually root). This is where `lgogdownloader` will place the game installers and associated files.

### `local.gog-downloader.interval`

*   **Type:**  `String`
*   **Default:** `"daily"`
*   **Description:**  Determines the interval at which the `lgogdownloader` service will run, defined using the systemd timer `OnCalendar` format. Common examples include `"daily"`, `"weekly"`, or a more specific schedule like `"*-*-* 03:00:00"`, which runs at 3:00 AM every day.  Consult the systemd.time documentation for valid formats.

### `local.gog-downloader.platforms`

*   **Type:**  `String`
*   **Default:** `"l+w"`
*   **Description:** Defines the platforms for which games should be downloaded.  It uses a shorthand notation:
    *   `l` - Linux
    *   `w` - Windows
    *   `m` - macOS

    Combining them with `+` allows downloading for multiple platforms. For example, `"l+w"` downloads both Linux and Windows versions.
### `local.gog-downloader.extraArgs`

*   **Type:**  `String`
*   **Default:** `"--repair --download"`
*   **Description:**  Allows you to pass additional arguments to `lgogdownloader`. The default arguments `--repair` forces the downloader to verify existing files and re-download corrupted ones, and `--download` instructs it to download missing files.  You can customize this to adjust the download behavior according to your needs. Examples:
    *   `--create-installers` to create offline installers.
    *   `--no-download` to only check for updates without downloading.
    *   `--chunk-size 1048576` to set a custom chunk size (in bytes).

### `local.gog-downloader.secretFile`

*   **Type:**  `Path`
*   **Description:** Path to a file containing environment variables required for GOG login.
    This file **must** be created manually and should contain the `GOG_EMAIL` and `GOG_PASSWORD` environment variables.

    **Important Security Note:** Ensure this file has restrictive permissions (e.g., `chmod 600 secret-file`) to protect your credentials.  Avoid committing this file to any version control system.

    The expected format of the file is:

    ```
    GOG_EMAIL=user@example.com
    GOG_PASSWORD=yourpassword
    ```

