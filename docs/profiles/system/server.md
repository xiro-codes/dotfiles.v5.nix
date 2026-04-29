# Server Profile

The Server profile provides the core infrastructure for the home network.

## Configuration Details

- **Location**: `systems/profiles/server/`
- **Modules**:
    - **`media.nix`**: Plex, Jellyfin, Komga, and Audiobookshelf.
    - **`networking.nix`**: Reverse proxy (Nginx) and Pi-hole.
    - **`services.nix`**: Gitea, Dashboard, and Harmonia cache.
    - **`sharing.nix`**: Samba sharing for the local network.
