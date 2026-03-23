```markdown
# nix-cache-client

This Nix module configures a system to use and upload to a custom binary cache server, specifically designed for use with Onix.  It sets up the necessary Nix settings to trust the cache, defines the server address, and adds a post-build hook to automatically upload newly built store paths to the cache. This enables faster builds and deployments by leveraging pre-built binaries. It also configures a post-build hook to automatically upload store paths to the Onix cache server.

## Options

This module provides the following options:

### `local.nix-cache-client.enable`

Type: Boolean

Default: `false`

Description:  Enables or disables the nix-cache-client module. When enabled, this module configures the system to use the specified binary cache and upload new builds to it.  Use `true` to activate the custom cache configuration and `false` to disable it (using the default Nix behavior).

### `local.nix-cache-client.serverAddress`

Type: String

Default: `"http://10.0.0.65:5000/?priority=1"`

Example: `"http://cache.example.com:8080/nixos?priority=10"`

Description: The URL of the Attic binary cache server to use. This option allows you to specify a custom binary cache server for Nix to download pre-built binaries from.  The `priority` parameter is optional and allows you to control the preference order of the cache.  Higher priority values are preferred.  Make sure the URL is accessible from the machine running Nix.

### `local.nix-cache-client.publicKey`

Type: String

Default: `"cache.onix.home-1:/M1y/hGaD/dB8+mDfZmMdtXaWjq7XtLc1GMycddoNIE="`

Example: `"cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz=="`

Description: The public key used to verify the integrity of binaries downloaded from the specified binary cache. This option ensures that the binaries you are using have not been tampered with.  The key should match the one used by the binary cache server.

## Configuration

When the `local.nix-cache-client.enable` option is set to `true`, the module configures the following Nix settings:

*   **`nix.settings.post-build-hook`**:  A script that automatically uploads newly built store paths to the Onix cache server. This ensures that any local builds are also available in the cache for future use.
*   **`nix.settings.trusted-users`**:  Adds `@wheel` to the list of trusted users. This is required to allow users in the `wheel` group to perform certain Nix operations.
*   **`nix.settings.substituters`**:  Adds the specified `serverAddress` and the default NixOS cache (`https://cache.nixos.org?priority=100`) to the list of substituters.  Substituters are the binary caches that Nix will use to download pre-built binaries.
*   **`nix.settings.trusted-public-keys`**:  Adds the specified `publicKey` and the default NixOS cache public key (`cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=`) to the list of trusted public keys.  Trusted public keys are used to verify the integrity of binaries downloaded from the substituters.

The module also ensures that `nix` is installed as a system package, although it is typically already installed.
```
