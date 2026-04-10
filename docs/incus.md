# incus

This module provides configuration options for setting up and managing Incus, a system container and virtual machine manager. It handles networking, storage, UI enablement, and reverse proxy configuration for accessing the Incus UI.  It leverages NixOS modules to configure networking, firewall rules, and the Incus service itself.

## Options

This module defines the following configuration options under `local.virtualisation.incus`:

### `enable`

Type:  Boolean

Default:  `false`

Description:  Enables or disables Incus virtualisation. When enabled, this module configures the necessary networking, firewall, and Incus service settings.

### `ui.enable`

Type:  Boolean

Default:  `false`

Description:  Enables or disables the Incus UI. Enabling this configures Incus to listen on a local HTTPS address and, optionally, configures a reverse proxy for access from other systems.

### `macvlanInterface`

Type:  Null or String

Default:  `null`

Description:  The physical interface to attach a macvlan network to. If set, a macvlan network named `macvlan0` will be created and attached to the specified interface. This allows Incus instances to directly access the external network. If `null`, no macvlan interface is created.

### `storageSource`

Type:  String

Default:  `"/var/lib/incus/storage"`

Description:  The path for the default storage pool. This specifies where Incus will store the data for its instances. Ensure that the specified path has sufficient storage capacity.  This option determines the `source` attribute for the default storage pool in Incus.

### `enableReverseProxy`

Type:  Boolean

Default:  `true`

Description:  Whether to configure the reverse proxy for the Incus UI/socket. If enabled, a reverse proxy is set up to forward requests to the Incus UI and socket, allowing access from other systems.  The reverse proxy uses the `local.reverse-proxy.services.vm` module and ensures that the `nginx` user is added to the `incus-admin` group. Setting this to false will disable the reverse proxy.

## Detailed Explanation and Usage Examples

This module simplifies the setup of Incus by automating several steps, including:

*   **Networking:** Configures a bridge interface (`incusbr0`) for internal networking and, optionally, a macvlan interface for direct external access.
*   **Firewall:** Enables the nftables firewall and trusts the `incusbr0` interface.
*   **Incus Service:** Enables the Incus service with a pre-defined configuration.
*   **Storage:** Configures a default storage pool using the specified `storageSource`.
*   **Reverse Proxy:** Optionally configures a reverse proxy (using `local.reverse-proxy.services.vm`) to allow access to the Incus UI from other systems.

**Example Configuration:**

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./reverse-proxy.nix # Assuming reverse-proxy module is defined here
  ];
  local.virtualisation.incus = {
    enable = true;
    ui.enable = true;
    macvlanInterface = "enp0s3";
    storageSource = "/mnt/storage/incus";
    enableReverseProxy = true;
  };
}
```

This example enables Incus, enables the UI, attaches a macvlan network to the `enp0s3` interface, sets the storage source to `/mnt/storage/incus`, and enables the reverse proxy.

**Important Considerations:**

*   **Storage:** Ensure that the `storageSource` path has sufficient storage capacity for your Incus instances.
*   **Networking:** If using a macvlan interface, ensure that the specified interface is correctly configured and connected to the external network.
*   **Reverse Proxy:** This module assumes the existence of a `local.reverse-proxy.services.vm` module. You may need to define this module separately, for example using nginx. Make sure that the module configures TLS certificates!
*   **Security:** The reverse proxy exposes your incus API.  If you disable the reverse proxy, you must have direct access to the incus host to use the UI.
*   **User Permissions:** The `nginx` user is automatically added to the `incus-admin` group when `enableReverseProxy` is true, granting it the necessary permissions to access the Incus socket.  If you use a different reverse proxy, you'll need to configure the user permissions manually.
