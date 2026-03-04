# `local.hosts` Module

This module provides a convenient way to manage and resolve hostnames on a local network. It defines static IP addresses and Avahi/mDNS hostnames for several machines (`onix`, `ruby`, `sapphire`) and allows you to choose whether to resolve these hosts using IP addresses or their `.local` Avahi domain names. It also updates `/etc/hosts` for more reliable name resolution. Finally, it exposes the resolved host addresses for use in other modules.

## Options

### `local.hosts.useAvahi`

Type: boolean

Default: `false`

Description:

Whether to use Avahi/mDNS hostnames (e.g., `.local`) instead of raw IP addresses for local network hosts. If set to `true`, the module will resolve the defined hosts (`onix`, `ruby`, `sapphire`) using their Avahi hostnames. If set to `false`, their IP addresses will be used.

Example:

```nix
local.hosts.useAvahi = true; # Resolve hosts using .local
```

### `local.hosts.onix`

Type: string

Default: Determined by `local.hosts.useAvahi`

Description:

Address for the Onix host.  This is read-only; its value is determined based on the `useAvahi` option and the defined IP address or Avahi hostname for `onix`.  Other modules can use this option to obtain the resolved address of the `onix` machine.

Example Usage:

```nix
{ config, ... }:
{
  systemd.services.my-service = {
    script = ''
      echo "Connecting to ${config.local.hosts.onix}"
    '';
  };
}
```

### `local.hosts.ruby`

Type: string

Default: Determined by `local.hosts.useAvahi`

Description:

Address for the Ruby host. This is read-only; its value is determined based on the `useAvahi` option and the defined IP address or Avahi hostname for `ruby`. Other modules can use this option to obtain the resolved address of the `ruby` machine.

Example Usage:

```nix
{ config, ... }:
{
  environment.variables.RUBY_HOST = config.local.hosts.ruby;
}
```

### `local.hosts.sapphire`

Type: string

Default: Determined by `local.hosts.useAvahi`

Description:

Address for the Sapphire host. This is read-only; its value is determined based on the `useAvahi` option and the defined IP address or Avahi hostname for `sapphire`. Other modules can use this option to obtain the resolved address of the `sapphire` machine.

Example Usage:

```nix
{ config, ... }:
{
  services.postgresql.hbaConfig = [
    "host all all ${config.local.hosts.sapphire}/32 trust"
  ];
}
```

## Details

This module also modifies the `/etc/hosts` file to include entries for `onix`, `ruby`, and `sapphire`. This ensures that these hostnames resolve to their corresponding IP addresses regardless of the `useAvahi` setting and even if Avahi is not running. Each host gets entries for the bare hostname, `.local`, and `.home` domains. This helps to improve reliability of name resolution within the local network.
