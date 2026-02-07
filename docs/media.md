# Media Stack

The `media` module provides a comprehensive home media server stack including Jellyfin, Plex, and ErsatzTV.

## Configuration

```nix
local.media = {
  enable = true;
  mediaDir = "/media/Media";
  
  jellyfin = {
    enable = true;
    openFirewall = true;
    subPath = "/jellyfin"; # For reverse proxy
  };
  
  plex = {
    enable = true;
    openFirewall = true;
  };
  
  ersatztv = {
    enable = true;
    openFirewall = true;
  };
};
```

## Directory Structure

The module expects (and creates) the following structure under `mediaDir`:
- `/movies`
- `/tv`
- `/music`

## Services

### Jellyfin
- **Port**: 8096
- **Config**: `/var/lib/jellyfin`
- **Reverse Proxy**: Automatically configures `network.xml` if `subPath` is set.

### Plex
- **Port**: 32400
- **User**: Runs as `tod` (group `users`).

### ErsatzTV
- **Port**: 8409
- **Type**: NixOS service
