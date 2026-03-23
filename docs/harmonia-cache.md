```markdown
# harmonia-cache

This Nix module provides configuration options for setting up an Attic binary cache server. It allows you to easily enable the server, configure its port, open the firewall for access, and specify the paths to the secret keys used for signing.

## Options

Here's a detailed breakdown of the available options within the `local.harmonia-cache` scope:

- **`local.harmonia-cache.enable`** (type: boolean, default: `false`)

  This option enables or disables the Attic binary cache server.  When set to `true`, the module will configure the `services.harmonia` service and potentially open the firewall as per the `openFirewall` setting.  Disabling this effectively turns off the cache server.

- **`local.harmonia-cache.port`** (type: port number, default: `5000`)

  This option specifies the HTTP port on which the cache server will listen for incoming connections.  A port number should be a valid integer representing an available port on the system. This is crucial for clients to be able to access the binary cache.

- **`local.harmonia-cache.openFirewall`** (type: boolean, default: `false`)

  Determines whether the firewall should be opened to allow traffic on the configured `port`. If set to `true`, the module will add a rule to the firewall allowing TCP connections on the specified port.  This is important for allowing other machines on the network to access the binary cache, however, setting to true without further securing the server can be dangerous.

- **`local.harmonia-cache.signKeyPaths`** (type: list of paths, default: `[]`)

  A list of paths to the secret keys used by the Attic server to sign binary caches.  These keys are essential for ensuring the integrity and authenticity of the cached data. Each path should point to a valid file containing a secret signing key. If no paths are provided, the server will not be able to sign caches.  This list should only contain paths to secure key files.
```
