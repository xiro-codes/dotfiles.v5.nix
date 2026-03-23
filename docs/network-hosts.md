```markdown
# network-hosts

This Nix module manages local network host configuration. It provides options to use either raw IP addresses or Avahi/mDNS hostnames for resolving local network hosts. It also configures the `/etc/hosts` file with static IP-to-hostname mappings for specific hosts (onix, ruby, sapphire).  This setup helps ensure reliable name resolution within a local network, especially when DHCP leases might change.

## Options

This module defines the following options under the `local.network-hosts` namespace:

-   **`local.network-hosts.useAvahi`**
    <sup>Type: boolean</sup>
    <sup>Default: `false`</sup>

    Whether to use Avahi/mDNS hostnames (e.g., `.local`) instead of raw IP addresses for local network hosts. When set to `true`, the module will attempt to resolve hosts using their Avahi names. When set to `false`, it uses the configured IP addresses directly. This option affects how hostnames are resolved for the `onix`, `ruby`, and `sapphire` hosts.

-   **`local.network-hosts.onix`**
    <sup>Type: string</sup>
    <sup>Default: _Dynamically evaluated to the IP or Avahi hostname of the "onix" host based on the `useAvahi` setting._</sup>
    <sup>Read-only</sup>

    The resolved address for the Onix host. This is either the IP address (e.g., `10.0.0.65`) or the Avahi hostname (e.g., `onix.local`), depending on the value of the `useAvahi` option.  This option is read-only, meaning it cannot be directly set by the user, but its value is dynamically calculated by the module based on the configuration.  You can reference this value in other modules that require the Onix host's address.

-   **`local.network-hosts.ruby`**
    <sup>Type: string</sup>
    <sup>Default: _Dynamically evaluated to the IP or Avahi hostname of the "ruby" host based on the `useAvahi` setting._</sup>
    <sup>Read-only</sup>

    The resolved address for the Ruby host. This is either the IP address (e.g., `10.0.0.66`) or the Avahi hostname (e.g., `ruby.local`), depending on the value of the `useAvahi` option.  This option is read-only, meaning it cannot be directly set by the user, but its value is dynamically calculated by the module based on the configuration.  You can reference this value in other modules that require the Ruby host's address.

-   **`local.network-hosts.sapphire`**
    <sup>Type: string</sup>
    <sup>Default: _Dynamically evaluated to the IP or Avahi hostname of the "sapphire" host based on the `useAvahi` setting._</sup>
    <sup>Read-only</sup>

    The resolved address for the Sapphire host. This is either the IP address (e.g., `10.0.0.67`) or the Avahi hostname (e.g., `sapphire.local`), depending on the value of the `useAvahi` option. This option is read-only, meaning it cannot be directly set by the user, but its value is dynamically calculated by the module based on the configuration. You can reference this value in other modules that require the Sapphire host's address.

## Configuration

In addition to the configurable options, this module configures the `/etc/hosts` file by adding the following entries:

-   `10.0.0.65 onix onix.local onix.home`
-   `10.0.0.66 ruby ruby.local ruby.home`
-   `10.0.0.67 sapphire sapphire.local sapphire.home`

These entries ensure that the hostnames `onix`, `ruby`, and `sapphire`, as well as their `.local` and `.home` variants, resolve to the specified IP addresses.  This provides a static and reliable way to resolve these hostnames, regardless of DHCP or DNS configurations.

## Usage Example

To enable Avahi/mDNS hostname resolution, add the following to your NixOS configuration:

```nix
{
  local.network-hosts.useAvahi = true;
}
```

This will configure the module to use `onix.local`, `ruby.local`, and `sapphire.local` as the addresses for the respective hosts. You can then refer to these addresses using the `config.local.network-hosts.onix`, `config.local.network-hosts.ruby`, and `config.local.network-hosts.sapphire` options in other modules.
```
