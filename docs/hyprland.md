# Hyprland Window Manager

The `hyprland` module configures a tiled Wayland compositor with a custom workflow focused on "Workspaces Sets".

## Configuration

```nix
local.hyprland.enable = true;
```

## Key Bindings

### Window Management

- `SUPER + Return`: Open terminal (kitty)
- `SUPER + Tab`: Switch to the next window
- `SUPER_SHIFT + Tab`: Switch to the previous window
- `SUPER_SHIFT + Q`: Close the active window
- `SUPER + F`: Toggle fullscreen for the active window
- `SUPER_SHIFT + F`: Toggle floating for the active window
- `SUPER + Space`: Swap the active window with the master window

### Application Launchers

- `SUPER + E`: Open file manager (pcmanfm)
- `SUPER_SHIFT + E`: Open terminal file manager (ranger)
- `SUPER + P`: Toggle launcher (caelestia)

### Workspace Management

- `SUPER + U`: Switch to workspace 'u'
- `SUPER + I`: Switch to workspace 'i'
- `SUPER + O`: Switch to workspace 'o'
- `SUPER_SHIFT + U`: Move active window to workspace 'u'
- `SUPER_SHIFT + I`: Move active window to workspace 'i'
- `SUPER_SHIFT + O`: Move active window to workspace 'o'

### Window Movement and Resizing

- `SUPER + H`: Move focus to the left
- `SUPER + J`: Move focus down
- `SUPER + K`: Move focus up
- `SUPER + L`: Move focus to the right
- `SUPER_SHIFT + H`: Move the active window to the left
- `SUPER_SHIFT + J`: Move the active window down
- `SUPER_SHIFT + K`: Move the active window up
- `SUPER_SHIFT + L`: Move the active window to the right
- `SUPER + mouse:272`: Move window with mouse
- `SUPER + mouse:273`: Resize window with mouse

## Workspace Workflow

This configuration uses a custom "Workspace Set" concept:

- **Switch Sets**: `Super + Tab` (Next), `Super + Shift + Tab` (Prev)
- **Direct Workspace**: `Super + U/I/O` (Selects workspace 1/2/3 within current set)
- **Move to Workspace**: `Super + Shift + U/I/O`

## Window Rules

- **Steam**: Friends, News, Settings, and Chat windows automatically float.
- **Focus**: Windows with class `steam_app_*` receive focus on activation.
