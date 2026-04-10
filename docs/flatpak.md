```markdown
# flatpak

This Nix module provides a convenient way to enable Flatpak support on your system, configure Flatpak remotes, and install Flatpak applications system-wide.  It simplifies the process of setting up Flatpak, ensuring that applications are installed consistently and automatically updated. It leverages the `services.flatpak` NixOS module under the hood.

## Options

This module defines the following options within the `local.flatpak` namespace:

### `local.flatpak.enable`

Type: `boolean`

Default: `false`

Description:
Enables or disables Flatpak support. Setting this option to `true` activates the module, configuring Flatpak services and installing specified packages.  When set to `false` the module has no effect. It is the primary switch to turn on or off Flatpak functionality controlled by this module. Enabling automatically sets up `services.flatpak.enable = true` within the NixOS configuration.

### `local.flatpak.extraPackages`

Type: `list of string`

Default: `[]` (empty list)

Description:
A list of Flatpak package names (application IDs) to install system-wide. These packages are added to the default application, "io.github.kolunmi.Bazaar", specified by the module, providing a means of automatically installing additional Flatpak applications.  These package names correspond directly to the application IDs found on platforms like Flathub.  For example, to install the GIMP image editor, you would add `"org.gimp.GIMP"` to this list. These are combined with the default `Bazaar` application, meaning that it will always be installed.

## Usage Example

To enable Flatpak support and install the `org.gimp.GIMP` Flatpak, add the following to your `configuration.nix`:

```nix
{
  imports = [
    ./modules/flatpak.nix  # Assuming the module is located at this path
  ];

  local.flatpak = {
    enable = true;
    extraPackages = [ "org.gimp.GIMP" ];
  };
}
```

This configuration will:

1.  Enable the Flatpak service.
2.  Add the Flathub remote (if it's not already added).
3.  Install both `io.github.kolunmi.Bazaar` and `org.gimp.GIMP` system-wide as Flatpak applications.
4.  Configure automatic Flatpak updates on system activation.

## Implementation Details

When `local.flatpak.enable` is set to `true`, the module:

*   Sets `services.flatpak.enable = true` to activate the Flatpak service in NixOS.
*   Enables automatic Flatpak updates on system activation using `services.flatpak.update.onActivation = true`.
*   Configures the Flathub remote using `services.flatpak.remotes`, ensuring that it's available for installing applications.
*   Installs the default application `io.github.kolunmi.Bazaar` and any applications specified in `local.flatpak.extraPackages` using `services.flatpak.packages`.

This module simplifies Flatpak management by encapsulating these configurations in a single, easy-to-use module.  It reduces boilerplate and provides a consistent way to manage Flatpak applications across different systems.
```
