```markdown
# secrets

This module provides a convenient way to manage secrets using sops-nix. It enables automatic decryption and mounting of secrets from an encrypted YAML file into `/run/secrets`, making them easily accessible system-wide. This configuration simplifies the process of managing sensitive data, such as passwords, API keys, and certificates, within a NixOS environment.

## Options

This module defines the following options under the `local.secrets` namespace:

- **`local.secrets.enable`** (type: boolean, default: `false`):

  Enables or disables the sops-nix secret management functionality. When enabled, the module will configure sops to decrypt and mount secrets specified in the `keys` option.

- **`local.secrets.sopsFile`** (type: path, default: `../../../secrets/secrets.yaml`):

  Specifies the path to the encrypted YAML file containing the secrets. This file should be encrypted using sops and contain key-value pairs where the keys correspond to the secret names you want to expose.

  *Example:*
    ```nix
    ../secrets/system-secrets.yaml
    ```
    This example indicates that the secrets are stored in a file named `system-secrets.yaml` located in the parent directory, then secrets.

- **`local.secrets.keys`** (type: list of strings, default: `[]`):

  A list of sops keys (i.e., secret names from the `sopsFile`) to automatically map to `/run/secrets/` for system-wide access. Each key in this list will have a corresponding file created in `/run/secrets/` with the decrypted value.

  *Example:*
    ```nix
    [ "onix_creds" "ssh_pub_ruby/master" "ssh_pub_sapphire/master" ]
    ```
    This example defines three secrets: `onix_creds`, `ssh_pub_ruby/master`, and `ssh_pub_sapphire/master`. After enabling the module and configuring sops correctly, these secrets will be available at `/run/secrets/onix_creds`, `/run/secrets/ssh_pub_ruby/master`, and `/run/secrets/ssh_pub_sapphire/master` respectively.

## Implementation Details

When `local.secrets.enable` is set to `true`, the module performs the following actions:

1.  Sets `sops.defaultSopsFile` to the value of `local.secrets.sopsFile`.
2.  Sets `sops.defaultSopsFormat` to `"yaml"` to ensure the sops plugin correctly parses the encrypted file.
3.  Configures `sops.age.sshKeyPaths` to include `/etc/ssh/ssh_host_ed25519_key`. This assumes that you are using an SSH key to decrypt your sops file; you may need to adjust this depending on your sops configuration. It's considered best practice to generate new age keys for server environment and rotate the /etc/ssh host keys!
4.  Generates the `sops.secrets` attribute set based on the `local.secrets.keys` list.  For each key in the list, a corresponding entry is created in `sops.secrets` with the following attributes:
    - `mode`: Set to `"0440"` to ensure secrets are readable only by the owner and group.
    - `owner`: Set to `"root"`.
    - `group`: Set to `"wheel"` allowing admins to read the secrets.

This configuration mounts the decrypted secrets into `/run/secrets` with appropriate file permissions, making them readily accessible to system services and applications that require them.  Remember to set appropriate `age.keyPaths` to ensure proper decryption.
```
