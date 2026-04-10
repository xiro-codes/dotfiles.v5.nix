# `local.network-hosts`

This Nix module provides a convenient way to manage local network hostnames and IP addresses. It defines a set of host mappings and exposes them as configuration options, allowing other modules to easily reference these hosts.  Additionally, it automatically populates the `/etc/hosts` file with the defined hostnames and IP addresses, ensuring reliable name resolution within the local network. This module also supports Avahi/mDNS for automatic hostname resolution.

## Options

This module defines the following options under the `local.network-hosts` scope:

### `local.network-hosts.useAvahi`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**

    Whether to use Avahi/mDNS hostnames (`.local`) instead of raw IP addresses for local network hosts.  When enabled, hostnames will resolve using mDNS.  When disabled, IP addresses will be used. This option affects the values of `onix`, `ruby`, and `sapphire` options and their resolution.

    Example:
    ```nix
    {
      local.network-hosts.useAvahi = true;
    }
    ```

    In this example, the `onix`, `ruby`, and `sapphire` options will resolve to addresses of the form `hostname.local` instead of raw IP addresses if they are defined.  If the hostnames aren't defined then they default to a standard host address, which if Avahi is on defaults to `hostname.local`

### `local.network-hosts.onix`

*   **Type:** `string`
*   **Default:** Evaluates to "onix.local" when `useAvahi` is `true`, and to "192.168.1.65" when `useAvahi` is `false`
*   **Read Only:** `true`
*   **Description:**

    Address for the Onix host. The value of this option depends on the `useAvahi` setting. If `useAvahi` is enabled, it will be `onix.local`; otherwise, it will be the IP address `192.168.1.65`.  This value is read-only and automatically derived from the module's internal definitions and the `useAvahi` setting.

    Example Usage:

    ```nix
    {
      services.example-service.settings.onix_address = config.local.network-hosts.onix;
    }
    ```

    This example showcases accessing the address of Onix from another module.

### `local.network-hosts.ruby`

*   **Type:** `string`
*   **Default:** Evaluates to "ruby.local" when `useAvahi` is `true`, and to "192.168.1.66" when `useAvahi` is `false`
*   **Read Only:** `true`
*   **Description:**

    Address for the Ruby host.  The value of this option depends on the `useAvahi` setting. If `useAvahi` is enabled, it will be `ruby.local`; otherwise, it will be the IP address `192.168.1.66`. This value is read-only and automatically derived from the module's internal definitions and the `useAvahi` setting.

    Example Usage:

    ```nix
    {
      services.another-service.settings.ruby_address = config.local.network-hosts.ruby;
    }
    ```

    This example demonstrates how other modules access the address of the Ruby host.

### `local.network-hosts.sapphire`

*   **Type:** `string`
*   **Default:** Evaluates to "sapphire.local" when `useAvahi` is `true`, and to "192.168.1.67" when `useAvahi` is `false`
*   **Read Only:** `true`
*   **Description:**

    Address for the Sapphire host.  The value of this option depends on the `useAvahi` setting. If `useAvahi` is enabled, it will be `sapphire.local`; otherwise, it will be the IP address `192.168.1.67`. This value is read-only and automatically derived from the module's internal definitions and the `useAvahi` setting.

    Example Usage:

    ```nix
    {
      programs.cool-tool.settings.sapphire_address = config.local.network-hosts.sapphire;
    }
    ```

    This demonstrates referencing the Sapphire host's address within another module.
