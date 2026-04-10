# registry

This Nix module manages a flake registry entry and NIX_PATH entry for the dotfiles repository. It allows referencing the dotfiles flake via the `dotfiles` alias. This is particularly useful for quickly accessing configurations and modules within the dotfiles repository using Nix commands. It also adds the dotfiles path to the NIX_PATH for compatibility with classic Nix commands.

## Options

### `local.registry.enable`

Type: Boolean

Default: `false`

Description: Enables or disables the dotfiles flake registry and NIX_PATH entry. When enabled, the module adds an entry to the Nix registry that allows referencing the dotfiles flake as `dotfiles`. It also adds an entry to `NIX_PATH` pointing to the dotfiles directory, ensuring that classic Nix commands can also locate the dotfiles.

## Details

When `local.registry.enable` is set to `true`, the following configurations are applied:

*   **Flake Registry Entry:**

    *   A registry entry named `dotfiles` is created. This entry allows you to refer to your dotfiles repository using the alias `dotfiles` in flake commands (e.g., `nix build dotfiles#my-config`).
    *   `from.type`: Specifies the type of source. Here, `indirect` means it refers to an existing flake identifier.
    *   `from.id`: Specifies the flake identifier.  Here, `dotfiles` is used as a convenient identifier.
    *   `to.type`: Specifies how the alias `dotfiles` is resolved. Here, `path` means it resolves to a filesystem path.
    *   `to.path`: Specifies the filesystem path to the dotfiles repository. Here it points to `/etc/nixos` as the root of the dotfiles.

*   **NIX_PATH Entry:**

    *   The module extends the `nix.nixPath` configuration option.
    *   `nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs`: Specifies the nixpkgs channel location for classic nix tools.
    *   `dotfiles=/etc/nixos`:  Adds `dotfiles` to the `NIX_PATH`, resolving to `/etc/nixos`. This allows you to use commands like `nix-build '<dotfiles/my-package>'` to build packages defined in your dotfiles.  This is important for backward compatibility with older Nix tools that rely on `NIX_PATH`.

## Example

To enable the dotfiles flake registry, add the following to your NixOS configuration:

```nix
{
  local.registry.enable = true;
}
```

This will add the `dotfiles` alias to your Nix registry and the dotfiles path to your `NIX_PATH`.
