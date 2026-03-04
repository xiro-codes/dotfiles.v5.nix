# registry

This Nix module configures a flake registry entry named `dotfiles` that points to the `/etc/nixos` directory. It's designed to make your dotfiles flake easily accessible by Nix commands.  This is especially useful when managing a NixOS system configuration with dotfiles stored within the `/etc/nixos` directory. It also configures the `NIX_PATH` environment variable to include an entry for 'dotfiles', ensuring that older Nix commands can also locate your configuration.

## Options

### `local.registry.enable`

Type: boolean

Default: `false`

Description: Enables or disables the flake registry configuration for dotfiles. When enabled, it creates a registry entry named `dotfiles` and configures `NIX_PATH`.

## Details

This module performs the following actions when `local.registry.enable` is set to `true`:

1.  **Flake Registry Entry:** Creates a flake registry entry named `dotfiles`.
    *   `from`: Specifies that the entry is an "indirect" entry identified by the id `dotfiles`.
    *   `to`:  Specifies that the entry resolves to a path type, specifically `/etc/nixos`. This is where your dotfiles flake (presumably containing your NixOS configuration) should reside.

    In effect, running `nix flake show dotfiles` will resolve to the contents of `/etc/nixos` as if it were a flake.

2.  **NIX_PATH Configuration:**  Adds a `dotfiles=/etc/nixos` entry to the `nix.nixPath`. This is important for older Nix commands (those that predate full flake support) that rely on the `NIX_PATH` environment variable to locate Nix expressions. This ensures that your dotfiles configuration is accessible even when using older tools. This means you can, for example, use `nix-build '<dotfiles>'` to build the default output of the flake in `/etc/nixos`.

3.  **nixpkgs Entry:** Includes `nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs` in `nix.nixPath`.  This is crucial for resolving dependencies and ensuring that the correct Nix packages are available. Note that this path is dependent on how nixpkgs is installed on the system, and this value is a very common default.

## Usage Example

To enable this module and make your dotfiles accessible, add the following to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include other modules here
    ];

  local.registry.enable = true;

  # ... other configuration ...
}
```

After rebuilding your system with `nixos-rebuild switch`, you can then use commands like:

*   `nix flake show dotfiles` - Inspect the flake located in `/etc/nixos`.
*   `nix build dotfiles#nixosConfigurations.my-system.config.system.build.toplevel` - build your system using flakes.
*   `nix-build '<dotfiles>'` - Build the default output of the flake (if defined).
