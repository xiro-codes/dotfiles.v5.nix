# gog-downloader

This Nix module provides a convenient way to automate the synchronization of your GOG library using `lgogdownloader`. It sets up a systemd timer and service to periodically download and update your games based on your specified configuration.  It also manages credentials via a file, which is the preferred way to interact with the downloader.

## Options

Here is a detailed breakdown of the available options within the `local.gog-downloader` scope:

-   **`enable`** (Type: boolean, Default: `false`):

    Enables the automated GOG library synchronization. When set to `true`, the module configures systemd services and timers to periodically run `lgogdownloader`.  Effectively turns on the whole module.
    This option is managed via `mkEnableOption`, which means setting `enable = true;` will activate the module.

-   **`directory`** (Type: path, Default: `"/media/Media/games"`):

    The absolute path to the directory where games downloaded from GOG will be stored. Ensure that the user executing the service has the necessary permissions to read and write to this directory.  This value should point to the root game folder.

-   **`interval`** (Type: string, Default: `"daily"`):

    Specifies the interval at which the GOG library synchronization should be performed. This value is passed directly to the systemd timer's `OnCalendar` setting.
    Examples:
    *   `"daily"`: Runs the synchronization every day.
    *   `"weekly"`: Runs the synchronization every week.
    *   `"*-*-01"`: Runs the synchronization on the first day of every month.
    *   `"0:00"`: Runs at midnight every day.
    Refer to the systemd.time documentation for more complex scheduling options.

-   **`platforms`** (Type: string, Default: `"l+w"`):

    Defines the platforms for which games should be downloaded. This option corresponds to the `--platform` argument of `lgogdownloader`.

    *   `"l"`: Linux
    *   `"w"`: Windows
    *   `"m"`: macOS

    Multiple platforms can be specified using the `+` separator. For example, `"l+w"` will download games for both Linux and Windows.  Using the plus symbol means 'and' in `lgogdownloader` speak.

-   **`extraArgs`** (Type: string, Default: `"--repair --download"`):

    A string containing extra arguments that will be passed directly to the `lgogdownloader` command. These arguments allow for customization of the download process.
    Common arguments include:
    *   `--repair`: Verifies existing installations and downloads missing or corrupted files.
    *   `--download`: Downloads the games (required for initial setup and updates).
    *   `--no-install`: Downloads only the files without attempting to install them.
    *   `--create-installers`: Creates installation files.
    *   `--chunk-size <size>`: set chunk size
    Consult the `lgogdownloader` documentation for a complete list of available arguments.

-   **`secretFile`** (Type: path, Description: Path to GOG Credentials):

    Specifies the path to a file containing the GOG account credentials. This file is loaded as environment variables for the `lgogdownloader` service, which `lgogdownloader` detects. This avoids hardcoding credentials directly into the Nix configuration.  The file should be readable by the user that the service runs as (typically root).
    The expected format of the file is:

    ```
    GOG_EMAIL=your_email@example.com
    GOG_PASSWORD=your_password
    ```

    It's extremely important to protect this file and restrict its access to prevent unauthorized access to your GOG account.
