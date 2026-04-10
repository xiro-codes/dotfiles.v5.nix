# harmonia-cache

This Nix module provides configuration options for setting up an Attic binary cache server, specifically designed for the Harmonia ecosystem. It allows you to easily enable and configure the cache server, including specifying the port it listens on, whether to open the firewall for access, and the paths to the secret keys used for signing the cache.

## Options

This module defines the following configuration options under the `local.harmonia-cache` scope:

- **`local.harmonia-cache.enable`** (type: boolean, default: `false`):

  Enables or disables the Attic binary cache server. When enabled, it configures the `services.harmonia.cache` service.  Disabling turns off the cache server.

- **`local.harmonia-cache.port`** (type: port, default: `5000`):

  Specifies the HTTP port on which the cache server will listen for incoming requests. This port should be a valid port number (typically between 1024 and 65535 to avoid conflicts with reserved ports and requiring root privileges).

- **`local.harmonia-cache.openFirewall`** (type: boolean, default: `false`):

  Determines whether the firewall should be opened to allow TCP traffic to the cache server's port. When set to `true`, the module will automatically add the specified port to the list of allowed TCP ports in the system's firewall configuration (`networking.firewall.allowedTCPPorts`).  Setting this to `true` makes the cache accessible from other machines on the network, but it's important to ensure other security measures are in place as well.

- **`local.harmonia-cache.signKeyPaths`** (type: list of paths, default: `[]`):

  A list of paths to the secret keys used for signing the binary cache. These keys are essential for ensuring the integrity and authenticity of the cached binaries.  The paths should point to valid files containing the secret keys.  These are passed directly to the underlying `services.harmonia.cache.signKeyPaths` option.  If empty, the cache will not be signed, and clients using the cache should be configured to trust unsigned caches.

## Usage

To enable and configure the Harmonia cache server, add the following to your NixOS configuration:

```nix
{
  local.harmonia-cache = {
    enable = true;
    port = 8080; # Example: Change the port to 8080
    openFirewall = true; # Example: Open the firewall
    signKeyPaths = [ "/path/to/secret.key" ]; # Example: Add the path to the secret key
  };
}
```

This example enables the cache server, sets the port to 8080, opens the firewall for that port, and specifies the path to the secret key.

**Important Considerations:**

- **Security:** If you set `openFirewall` to `true`, ensure that your firewall is properly configured to restrict access to the cache server from untrusted sources.
- **Signing Keys:** Protect your signing keys carefully, as they are crucial for the security of your binary cache.  Consider storing these keys in a secure location and restricting access to them.
- **Dependencies:**  This module relies on the `services.harmonia.cache` service being available.  Ensure that you have the Harmonia services module configured correctly as well.
- **Clients:**  Clients accessing the cache must be configured to either trust the signing key (if the cache is signed) or trust unsigned caches (if `signKeyPaths` is empty).
