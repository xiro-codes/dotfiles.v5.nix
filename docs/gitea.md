# Gitea Service

The `gitea` module sets up a self-hosted Git service with built-in Actions support.

## Configuration

```nix
local.gitea = {
  enable = true;
  domain = "git.example.com";
  port = 3001;
  sshPort = 2222;
  openFirewall = true;
};
```

## Features

- **Database**: SQLite3 at `/var/lib/gitea/data/gitea.db`
- **Actions**: Enabled by default.
- **SSH Passthrough**: Configures a dedicated SSH port (default 2222) to avoid conflict with system SSH.
- **Reverse Proxy**: Automatically calculates URLs based on the `reverse-proxy` module settings.

## Integration

To use with the `reverse-proxy` module:

```nix
local.reverse-proxy = {
  enable = true;
  domain = "example.com";
};

local.gitea.enable = true;
# Result: Gitea available at https://git.example.com
```
