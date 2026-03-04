# cache-server

This Nix module configures and enables a local Attic binary cache server using the `harmonia` service. It provides options to control the server's port, firewall settings, and the path to the signing key. When enabled, it sets up the `harmonia` service and optionally opens the firewall for the specified port.

## Options

This module defines the following options under the `local.cache-server` namespace:

### `local.cache-server.enable`

**Type:** Boolean

**Default:** `false`

**Description:** Enables or disables the Attic binary cache server. When set to `true`, the module will configure and start the `harmonia` service.

### `local.cache-server.port`

**Type:** Port (Integer between 1 and 65535)

**Default:** `5000`

**Description:**  The HTTP port on which the cache server will listen for incoming requests.  This value determines which port the `harmonia` service will bind to.  It's important to choose a port that is not already in use by another service on your system to avoid conflicts.

### `local.cache-server.openFirewall`

**Type:** Boolean

**Default:** `false`

**Description:** Determines whether the firewall should be configured to allow incoming TCP connections to the cache server on the specified port. Setting this to `true` will automatically add the `local.cache-server.port` to the list of allowed TCP ports in the system's firewall configuration.  It is generally recommended to enable this option if you intend to access the cache server from other machines on your network, but be mindful of security implications if you are exposing the server to the public internet.

### `local.cache-server.signKeyPath`

**Type:** Path

**Default:** `""` (Empty String)

**Description:** The absolute path to the secret key used to sign the binary cache. This is essential for ensuring the integrity and authenticity of the cached artifacts. `harmonia` uses this key to sign the artifacts it serves. An empty string disables signing.

## Usage Example

To enable the cache server on port 8080, open the firewall, and specify the signing key path, you can add the following to your NixOS configuration:

```nix
{
  local.cache-server = {
    enable = true;
    port = 8080;
    openFirewall = true;
    signKeyPath = "/path/to/your/secret-key";
  };
}
```

## Implementation Details

When `local.cache-server.enable` is set to `true`, the following configuration changes are applied:

*   The `services.harmonia.enable` option is set to `true`, starting the `harmonia` service.
*   The `services.harmonia.signKeyPath` option is set to the value of `local.cache-server.signKeyPath`.
*   If `local.cache-server.openFirewall` is set to `true`, the `local.cache-server.port` is added to the `networking.firewall.allowedTCPPorts` list. This will open the firewall for the specified port, allowing incoming TCP connections to the cache server.
