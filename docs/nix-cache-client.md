# nix-cache-client

This module configures a Nix client to use a custom binary cache server, primarily for development or local network scenarios. It sets up Nix to push build artifacts to the specified cache after a build, and also configures it to trust and fetch artifacts from that cache. This is useful for speeding up builds on multiple machines within a local network or for sharing development builds.

## Options

### `local.nix-cache-client.enable`

Type: boolean

Default: `false`

Description: Enables the Nix cache client module. When enabled, this module configures the Nix settings to use the specified binary cache server and public key.

### `local.nix-cache-client.serverAddress`

Type: string

Default: `"http://192.168.1.65:5000/?priority=1"`

Example: `"http://cache.example.com:8080/nixos?priority=10"`

Description: The URL of the binary cache server. This address should include the scheme (e.g., `http://` or `https://`) and can optionally include a `priority` parameter.  Higher priority caches are preferred. Ensure the server is accessible from the Nix client.

### `local.nix-cache-client.publicKey`

Type: string

Default: `"cache.onix.home-1:/M1y/hGaD/dB8+mDfZmMdtXaWjq7XtLc1GMycddoNIE="`

Example: `"cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz=="`

Description: The public key used to verify signatures from the binary cache. This key must match the private key used by the cache server to sign its metadata. This is crucial for security, as it ensures that the downloaded artifacts are authentic and haven't been tampered with.  Obtain this key directly from the cache server administrator.

## Details and Functionality

When the `local.nix-cache-client.enable` option is set to `true`, the following configurations are applied:

*   **`post-build-hook`**:  A shell script (`upload-to-onix`) is created and set as the `post-build-hook`. This script is executed after every Nix build. It identifies the store paths that were just built (contained in the `$OUT_PATHS` variable) and attempts to copy them to the specified `serverAddress` using `nix copy`. The `|| true` ensures that build failures aren't triggered by upload failures.  The script internally uses the standard `nix copy` command.

*   **`trusted-users`**: Adds `@wheel` to the `trusted-users` list.  This setting allows users in the `wheel` group to perform actions like importing from unsigned caches (though this module also adds the cache to `trusted-public-keys`, making this less critical here).

*   **`substituters`**:  Adds the `serverAddress` and `"https://cache.nixos.org?priority=100"` to the list of substituters. Nix will attempt to download pre-built binaries from these locations before building from source.  The priority parameter influences which cache is preferred when multiple caches contain the same packages.

*   **`trusted-public-keys`**:  Adds both the `publicKey` and `"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="` to the list of trusted public keys.  Nix verifies the signatures of the cache metadata using these keys to ensure the integrity of the downloaded binaries.

## Usage Notes

*   **Security:**  It is crucial to obtain the correct `publicKey` from the administrator of the binary cache server and to ensure that the server is trustworthy, especially in production environments.  Using untrusted caches can introduce security vulnerabilities.

*   **Networking:** The Nix client must be able to connect to the `serverAddress`.  Ensure that there are no firewall rules or network configurations preventing the client from accessing the server.

*   **Priorities:**  The `priority` parameter in the `serverAddress` URL and in the standard NixOS cache URL affects which cache is preferred. Higher values mean higher priority.

*   **Error Handling:** The `uploadScript` uses `|| true` to prevent upload failures from causing build failures. This ensures that builds can continue even if the cache server is temporarily unavailable. However, it also means that upload failures will not be immediately apparent. Consider adding more robust error handling to the script if reliable uploading is essential.
