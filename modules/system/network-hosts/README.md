# Host Management Module

This module provides centralized management of local network hosts with support for toggling between raw IP addresses and Avahi/mDNS hostnames.

## Usage

Enable and configure in your system configuration:

```nix
{
  local.hosts = {
    # Toggle between IPs and .local hostnames
    useAvahi = true;  # Use onix.local, ruby.local, sapphire.local
    # useAvahi = false; # Use 10.0.0.65, 10.0.0.66, 10.0.0.67
  };
}
```

## Features

- **Centralized Host Definitions**: All local network hosts defined in one place
- **Automatic Resolution**: Other modules automatically use the resolved addresses
- **Avahi/mDNS Support**: Toggle between raw IPs and .local hostnames
- **Single Source of Truth**: IP addresses are only defined in this module
- **/etc/hosts Integration**: Adds hostname mappings when Avahi mode is enabled

## Defined Hosts

| Host Name | IP Address  | Avahi Hostname  |
|-----------|-------------|-----------------|
| onix    | 10.0.0.65   | onix.local    |
| ruby      | 10.0.0.66   | ruby.local      |
| sapphire  | 10.0.0.67   | sapphire.local  |

## Modules Using Host Configuration

The following modules automatically use centralized host configuration:

**System Modules:**
- `cache` - Uses onix for Attic cache server
- `share-manager` - Uses onix for SMB/CIFS server
- `dotfiles` - Uses onix for Gitea server

**Home Modules:**
- `system-config.cache` - Uses onix for cache server
- `system-config.ssh` - Uses ruby and sapphire for SSH hosts
- `system-config.ssh` - Uses onix for Gitea SSH

## Requirements

When using Avahi mode (`useAvahi = true`):
- Ensure Avahi is enabled on all hosts (typically via `local.network.enable = true` which enables avahi)
- All hosts must advertise their `.local` hostnames
- mDNS resolution must work on the network

## Examples

### Use Avahi hostnames everywhere
```nix
{
  local.hosts.useAvahi = true;
  # Now all modules will use onix.local instead of 10.0.0.65
}
```

### Use raw IPs (default)
```nix
{
  local.hosts.useAvahi = false;
  # All modules will use 10.0.0.65 instead of onix.local
}
```

### Access resolved addresses in custom modules
```nix
{
  # The resolved address is available as a read-only option
  services.myservice.server = config.local.hosts.onix;
}
```
