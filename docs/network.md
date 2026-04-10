# network

This module configures the standard system networking for a NixOS system. It allows enabling/disabling the networking stack, choosing between NetworkManager and a minimal iwd/systemd setup, and prioritizing a local Pi-hole for DNS resolution. It also configures iwd, firewall rules, Avahi and optionally enables systemd-resolved.

## Options

### `local.network.enable`

Type: `boolean`

Default: `false`

Description: Enables or disables the standard system networking module.  When enabled, configures various networking components, including iwd, NetworkManager (optional), firewall rules, and DNS settings. This is the main switch for activating the networking configurations provided by this module.

### `local.network.useNetworkManager`

Type: `boolean`

Default: `true`

Description: Determines whether to use NetworkManager for handling network connections, primarily intended for desktop environments.  If set to `true`, NetworkManager is enabled and configured to use iwd as the Wi-Fi backend. If `false`, a more minimal setup using iwd and systemd is employed, suitable for headless servers or environments where NetworkManager is not desired.

### `local.network.usePihole`

Type: `boolean`

Default: `true`

Description: Configures the system to prioritize a local Pi-hole instance (assumed to be at `192.168.1.65`) for DNS resolution.  If set to `true`, the Pi-hole IP address is added to the list of nameservers, ensuring that DNS queries are first directed to the Pi-hole for ad blocking and local network name resolution. If `false`, a standard set of public DNS servers (Google and Cloudflare) is used instead.

## Detailed Configuration Breakdown:

When `local.network.enable` is set to `true`, the following configurations are applied:

*   **`networking.wireless.enable = false;`**:  Disables the old `wpa_supplicant`, likely to avoid conflicts with iwd or NetworkManager.
*   **`networking.firewall.allowedTCPPorts = [ 5201 5202 ];`**:  Opens TCP ports 5201 and 5202 in the firewall.  These are typically used by `iperf3` for network performance testing, so this suggests the system may be used for such testing.
*   **`networking.nameservers = ...;`**: Sets the DNS nameservers based on the `local.network.usePihole` option. If `usePihole` is `true`, it prioritizes the Pi-hole IP address (`192.168.1.65`) followed by Google's public DNS (`8.8.8.8`).  Otherwise, it uses Google's DNS (`8.8.8.8`) and Cloudflare's DNS (`1.1.1.1`).
*   **`networking.wireless.iwd = { ... };`**: Enables and configures iwd (iNet Wireless Daemon) for wireless networking.  It sets `AutoConnect = true` for automatic connection to known Wi-Fi networks and `EnableIPv6 = true` to enable IPv6 support.
*   **`networking.networkmanager = mkIf cfg.useNetworkManager { ... };`**: Conditionally enables and configures NetworkManager based on the `local.network.useNetworkManager` option.
    *   If `useNetworkManager` is `true`, NetworkManager is enabled, its Wi-Fi backend is forced to `iwd`, and it configures its nameservers to prioritize Pi-hole if configured.
*   **`networking.useDHCP = mkDefault true;`**: Enables DHCP (Dynamic Host Configuration Protocol) for Ethernet interfaces, using `mkDefault` making it easier to override if needed.
*   **`services.avahi = { ... };`**: Configures Avahi, a system for local network service discovery. It disables Avahi initially, then enables `nssmdns4`, allows publishing of services, addresses, and sets the workstation option.
*   **`services.resolved.enable = false;`**: Disables `systemd-resolved`. Enabling `systemd-resolved` could provide better DNS handling.

This module provides a flexible and configurable way to manage networking on a NixOS system, allowing users to choose between NetworkManager and a minimal setup, prioritize a Pi-hole for DNS resolution, and configure other networking services.

