# Containers

This module provides automated management for NixOS containers. It discovers container definitions in the `systems/containers/` directory and generates options to enable them on host systems.

## Usage

To enable a container on a host, add its name to the `local.containers` option in the host's configuration:

```nix
local.containers.jade.enable = true;
```

## Structure

Containers are defined in subdirectories of `systems/containers/`. Each container directory must contain:
- `configuration.nix`: The NixOS configuration for the container.
- `hardware-configuration.nix`: Platform-specific settings (usually minimal for containers).

## Options

The module automatically generates options for each discovered container. It links these to the `nixosContainers` flake output.

### `local.containers.<name>.enable`
- **Type:** Boolean
- **Default:** `false`
- **Description:** Whether to enable the container on this host.

### `local.containers.<name>.autoStart`
- **Type:** Boolean
- **Default:** `true`
- **Description:** Whether to automatically start the container on host boot.

### `local.containers.<name>.privateNetwork`
- **Type:** Boolean
- **Default:** `true`
- **Description:** Whether the container should have its own private network stack.

### `local.containers.<name>.macvlans`
- **Type:** List of Strings
- **Default:** `[ "enp6s0" ]`
- **Description:** Network interfaces to pass to the container using macvlan.
