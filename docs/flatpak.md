# flatpak

This module provides a convenient way to enable and configure Flatpak support on your NixOS system. It simplifies the installation of Flatpak itself, configures automatic updates, adds the Flathub repository, and allows you to specify a list of Flatpak packages to be installed system-wide.

## Options

This module exposes the following options under the `local.flatpak` namespace:

### `local.flatpak.enable`

*   **Type:** `types.bool` (boolean)
*   **Default:** `false`
*   **Description:** Enables or disables Flatpak support. When enabled, the module configures Flatpak services and installs specified packages.

    **Example:**

    To enable flatpak set this option to true

    ```nix
    local.flatpak.enable = true;
    ```

### `local.flatpak.extraPackages`

*   **Type:** `types.listOf types.str` (list of strings)
*   **Default:** `[]` (empty list)
*   **Description:** A list of Flatpak package names to install system-wide in addition to the default `io.github.kolunmi.Bazaar` application.  Each element of the list should be a string representing the full Flatpak application ID (e.g., `org.mozilla.firefox`).

    **Example:**

    To install Firefox and LibreOffice as Flatpaks, configure the option as follows:

    ```nix
    local.flatpak.enable = true;
    local.flatpak.extraPackages = [
      "org.mozilla.firefox"
      "org.libreoffice.LibreOffice"
    ];
    ```

## Configuration Details

When `local.flatpak.enable` is set to `true`, the following configurations are applied:

*   **`services.flatpak.enable = true;`**:  Enables the Flatpak system service, making Flatpak available on your system.
*   **`services.flatpak.update.onActivation = true;`**: Configures Flatpak to automatically update its packages whenever the NixOS configuration is activated (e.g., after running `nixos-rebuild switch`). This ensures that your Flatpak applications are always up-to-date.
*   **`services.flatpak.remotes = [{ name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo"; }];`**: Adds the Flathub repository, the most common and comprehensive Flatpak repository, to your Flatpak configuration.  This allows you to easily install applications available on Flathub. The `name` "flathub" is used as the alias and the `location` specifies the URL of the repository configuration file.
*   **`services.flatpak.packages = [ "io.github.kolunmi.Bazaar" ] ++ cfg.extraPackages;`**:  Specifies the list of Flatpak packages to be installed system-wide.  It automatically includes the `io.github.kolunmi.Bazaar` application and concatenates it with the list provided via the `local.flatpak.extraPackages` option.  This ensures that all listed applications are installed whenever the NixOS configuration is applied.

## Usage Example

To enable Flatpak, add the Flathub repository, configure automatic updates, and install Firefox and Bazaar, use the following configuration in your `configuration.nix`:

```nix
{
  imports = [
    ./path/to/this/module.nix  # Replace with the actual path to this module
  ];

  local.flatpak.enable = true;
  local.flatpak.extraPackages = [
    "org.mozilla.firefox"
  ];
}
```

After adding this configuration, run `sudo nixos-rebuild switch` to apply the changes. Flatpak will be enabled, Flathub added as a remote, and both Bazaar and Firefox will be installed as Flatpak applications. Subsequent rebuilds will ensure the apps are up to date.
