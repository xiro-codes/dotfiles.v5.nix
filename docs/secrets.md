# secrets

This Nix module provides a convenient way to manage system secrets using `sops-nix`. It enables encryption and decryption of secrets stored in a YAML file, making them accessible to your NixOS configuration.  The module automatically maps specified secrets to `/run/secrets/` to provide system-wide access, configuring the owner, group, and permissions for each secret. It also configures the global sops settings.

## Options

This module exposes the following options under the `local.secrets` namespace:

### `local.secrets.enable`

Type: `boolean`

Default: `false`

Description: Enables or disables the `sops-nix` secret management integration. When enabled, the module configures `sops` to decrypt secrets from the specified file and make them available.  This option is the primary switch to turn on all functionality described here.

### `local.secrets.sopsFile`

Type: `path`

Default: `../../../secrets/secrets.yaml`

Example: `../secrets/system-secrets.yaml`

Description: Specifies the path to the encrypted YAML file containing your system secrets. This file should be encrypted using `sops`. The `defaultSopsFile` option of sops-nix will be set to this path. It is used to configure where the module reads secret values from. It's recommended to store this file in a secure location. This supports relative paths, which are resolved relative to the module file.

### `local.secrets.keys`

Type: `list of string`

Default: `[ ]`

Example: `[ "onix_creds" "ssh_pub_ruby/master" "ssh_pub_sapphire/master" ]`

Description: A list of `sops` keys to automatically map to `/run/secrets/` for system-wide access. Each string in the list corresponds to a top-level key within your encrypted YAML file. These keys will be created as secrets in sops-nix.

When this module is enabled (`local.secrets.enable = true`), the listed secrets will be mounted in `/run/secrets/`, which is a common location for system services to access sensitive information. This is facilitated through `lib.genAttrs` and `sops.secrets`. The module will set the specified permissions for each generated entry, using the default values provided in the module. Each secret will be accessible as a file within the `/run/secrets/` directory, named after its corresponding key. The file contains the decrypted value of the secret.

## Configuration Details

When `local.secrets.enable` is set to `true`, the module automatically configures the `sops` options, using `sops-nix` underneath:

*   `sops.defaultSopsFile` is set to the value of `cfg.sopsFile`.
*   `sops.defaultSopsFormat` is set to `"yaml"`.
*   `sops.age.sshKeyPaths` is set to `[ "/etc/ssh/ssh_host_ed25519_key" ]`.  This is required to automatically decrypt secrets on boot. Make sure to regenerate these host keys if deploying from an image.
*   For each key in `cfg.keys`, a corresponding secret entry is generated under `sops.secrets`. These secrets are configured with:
    *   `mode = "0440"` (read permissions for root and the wheel group).
    *   `owner = "root"` (owned by the root user).
    *   `group = "wheel"` (belonging to the wheel group).
