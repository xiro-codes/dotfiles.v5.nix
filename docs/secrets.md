# Secret Management

This document outlines how to manage secrets in this dotfiles repository. We use [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets, with [age](https://github.com/FiloSottile/age) as the encryption backend.

## Overview

Secrets are stored in `secrets/secrets.yaml`, which is encrypted using `sops`. The keys are encrypted with `age` and can be decrypted by anyone with a corresponding `age` private key.

The `flake.nix` file is configured to use `sops-nix`, which makes the secrets available to your NixOS and home-manager configurations.

## Adding a New Secret

To add a new secret, you need to edit the `secrets/secrets.yaml` file. You can do this by running:

```bash
sops secrets/secrets.yaml
```

This will open the file in your default editor. You can then add a new key-value pair to the file. For example:

```yaml
my_new_secret:
  api_key: "my-secret-value"
```

When you save and close the file, `sops` will automatically encrypt the new secret.

## Accessing Secrets in Nix Configurations

To access a secret in a Nix configuration, you need to add it to the `sops.secrets` attribute in the appropriate file. For example, to make a secret available to the `tod@Onix.nix` host, you would add the following to `home/tod@Onix.nix`:

```nix
{
  # ...
  sops.secrets.my_new_secret = {
    # The path to the secret in the secrets.yaml file
    key = "my_new_secret.api_key";
  };
  # ...
}
```

The secret will then be available at `/run/secrets/my_new_secret` on the `Onix` machine.

## Editing Existing Secrets

To edit an existing secret, you can use the same process as adding a new secret:

```bash
sops secrets/secrets.yaml
```

This will open the encrypted file in your editor, allowing you to change the value of any secret. When you save the file, `sops` will re-encrypt it with the updated values.

## Adding a New Machine or User

To give a new machine or user access to the secrets, you need to add their `age` public key to the `.sops.yaml` file in the root of the repository.

First, get the `age` public key from the new machine or user. Then, open the `secrets/secrets.yaml` file with `sops`:

```bash
sops secrets/secrets.yaml
```

Then, add the new public key to the `sops.age.recipients` list:

```yaml
sops:
  age:
    - recipient: "age1..."
    - recipient: "age2..."
    - recipient: "new_age_public_key"
```

Save and close the file. `sops` will re-encrypt the file with the new recipient's public key, giving them access to the secrets. You will need to rekey the secrets for them to be able to decrypt them. You can do this by running the following command:

```bash
sops updatekeys secrets/secrets.yaml
```

After this, the new machine or user will be able to decrypt the secrets.
