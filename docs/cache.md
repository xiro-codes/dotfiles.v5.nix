# Cache

This module configures a Nix binary cache, allowing for faster builds by utilizing pre-built packages from a remote server. It sets up the necessary Nix settings to trust and use the specified cache, and it also includes a post-build hook to automatically upload newly built packages to an Onix cache.

## Options

Here's a breakdown of the configurable options within the `local.cache` namespace:

-   **`local.cache.enable`** (type: boolean, default: `false`)

    Enables or disables the cache module.  When enabled, the module configures Nix to use the specified binary cache and sets up a post-build hook to upload newly built packages.  This is the primary switch to control whether or not this entire module has any effect.

-   **`local.cache.serverAddress`** (type: string, default: `"http://10.0.0.65:5000/?priority=1"`)

    Specifies the URL of the Attic binary cache server to use.  This should include the base URL of the cache server, and can optionally include a `priority` parameter to influence Nix's selection of caches.  Higher priority caches will be preferred.  It is critical that this is set correctly to point to the correct caching server.

    *Example:* `"http://cache.example.com:8080/nixos?priority=10"`

-   **`local.cache.publicKey`** (type: string, default: `"cache.onix.home-1:/M1y/hGaD/dB8+mDfZmMdtXaWjq7XtLc1GMycddoNIE="`)

    The public key used to verify the integrity of packages downloaded from the binary cache.  This key must match the private key used to sign the packages on the cache server.  Incorrect or missing public keys will cause Nix to refuse to use the cache. This is a critical security component.

    *Example:* `"cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz=="`

## Module Configuration

When `local.cache.enable` is set to `true`, the module configures Nix with the following settings:

-   **`nix.settings.post-build-hook`**: Sets a post-build hook that runs after each package is built. This hook executes a script that attempts to upload the built packages to the Onix cache server (located at `http://10.0.0.65:5000`). The upload is done via `nix copy`.  If the upload fails, the script continues without erroring thanks to `|| true`. This ensures builds don't fail just because the cache upload failed.
-   **`nix.settings.trusted-users`**: Adds the `@wheel` group to the list of trusted users. This allows members of the `wheel` group to perform certain Nix operations, like building derivations.
-   **`nix.settings.substituters`**: Configures the list of binary caches Nix will use. It includes both the configured `local.cache.serverAddress` and the official NixOS cache (`https://cache.nixos.org?priority=100`).  The priority parameter influences which cache Nix prefers.
-   **`nix.settings.trusted-public-keys`**: Adds the configured `local.cache.publicKey` and the official NixOS cache public key (`cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=`) to the list of trusted public keys.  This allows Nix to verify packages downloaded from these caches.

The module also ensures that no additional `systemPackages` are installed by default by setting `environment.systemPackages = with pkgs; [ ];`.
