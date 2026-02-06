# Hyprland Window Manager

The `hyprland` module configures a tiled Wayland compositor with a custom workflow focused on "Workspaces Sets".

## Configuration

```nix
local.hyprland.enable = true;
```

## Key Bindings

| Key | Action |
| --- | --- |
| `Super + Return` | Terminal |
| `Super + E` | GUI File Manager |
| `Super + Shift + E` | Terminal File Manager |
| `Super + P` | Launcher |
| `Super + F` | Fullscreen |
| `Super + Space` | Swap with Master |

## Workspace Workflow

This configuration uses a custom "Workspace Set" concept:

- **Switch Sets**: `Super + Tab` (Next), `Super + Shift + Tab` (Prev)
- **Direct Workspace**: `Super + U/I/O` (Selects workspace 1/2/3 within current set)
- **Move to Workspace**: `Super + Shift + U/I/O`

## Window Rules

- **Steam**: Friends, News, Settings, and Chat windows automatically float.
- **Focus**: Windows with class `steam_app_*` receive focus on activation.
