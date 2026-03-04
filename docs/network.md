# network

This module configures standard system networking, providing options to choose between NetworkManager (for desktop environments) or a minimal setup with iwd/systemd. It sets up wireless networking using iwd, configures DNS servers, and enables basic Ethernet support via DHCP. It also includes options to enable or disable NetworkManager, Avahi, and systemd-resolved.

## Options

### `local.network.enable`

Type: boolean

Default: `false`

Description: Enables the standard system networking configuration provided by this module.  When set to true, the module will configure iwd, DNS servers, DHCP, and optionally NetworkManager and Avahi.  Setting this to `true` activates all the features detailed below. This is the master switch for this entire module.  If this is false, none of the other options have any effect.

### `local.network.useNetworkManager`

Type: boolean

Default: `true`

Description:  Determines whether to use NetworkManager for managing network connections (typically used on desktop environments). If set to `true`, NetworkManager will be enabled, and configured to use iwd as its Wi-Fi backend.  If set to `false`, a minimal network configuration using iwd and systemd will be used, omitting NetworkManager entirely. Disabling NetworkManager can be useful for server environments or systems where a lightweight network setup is preferred.

## Detailed Configuration

When `local.network.enable` is set to `true`, the following configurations are applied:

*   **Networking:**
    *   `networking.wireless.enable = false;`: Disables the older `wpa_supplicant`. This is done because iwd is used instead.
    *   `networking.nameservers = [ "10.0.0.65" "8.8.8.8" ];`: Sets the DNS nameservers. The module defaults to `10.0.0.65` and Google's public DNS (`8.8.8.8`). You should customize this to your local network's DNS server, or other public DNS servers.
    *   **iwd:**
        *   `networking.wireless.iwd.enable = true;`: Enables iwd (iNet Wireless Daemon) for managing wireless connections. iwd is generally considered faster and more modern than `wpa_supplicant`.
        *   `networking.wireless.iwd.settings`:
            *   `Settings.AutoConnect = true;`:  Configures iwd to automatically connect to known Wi-Fi networks. This provides a seamless connection experience.
            *   `Network.EnableIPv6 = true;`: Enables IPv6 support within iwd. If your network supports IPv6, this allows your system to utilize it.

    *   **NetworkManager (Conditional):** Enabled only when `local.network.useNetworkManager` is `true`.
        *   `networking.networkmanager.enable = true;`: Enables NetworkManager.
        *   `networking.networkmanager.wifi.backend = "iwd";`: Forces NetworkManager to use iwd as its Wi-Fi backend.  This ensures that NetworkManager utilizes the modern iwd daemon for wireless management.

    *   `networking.useDHCP = lib.mkDefault true;`: Enables DHCP (Dynamic Host Configuration Protocol) on all Ethernet interfaces starting with the letter 'e'. This automatically obtains an IP address, subnet mask, and default gateway from the DHCP server on your network, simplifying network configuration.  This is applied as a default, so it can be overridden elsewhere if needed.

*   **Avahi (Multicast DNS):**
    *   `services.avahi.enable = false;`: Disables avahi
    *   `services.avahi.nssmdns4 = true;`: Enables multicast DNS for IPv4 resolution.
    *   `services.avahi.publish`: Configures Avahi to publish certain services.
        *   `services.avahi.publish.enable = true;`: Enables publishing services via Avahi.
        *   `services.avahi.publish.addresses = true;`: Publishes the system's IP addresses via Avahi.
        *   `services.avahi.publish.workstation = true;`: Publishes the system as a workstation, making it discoverable on the network.

*   **systemd-resolved (Optional):**
    *   `services.resolved.enable = false;`: Disables systemd-resolved.
