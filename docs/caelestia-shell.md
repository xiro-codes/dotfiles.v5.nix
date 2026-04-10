```markdown
# caelestia-shell

This Nix module configures and enables the Caelestia shell application, providing a customized desktop environment with specific applications, settings, and idle behavior. It also manages dependencies, configures idle timeouts, and sets up a custom shutdown script triggered after a period of inactivity.

## Options

### `local.caelestia-shell.enable`

Type: `boolean`

Default: `false`

Description: Enables or disables the Caelestia shell application.  Setting this to `true` activates the module's configurations, including package installation, Caelestia settings, and idle shutdown behavior.

### `local.caelestia-shell.idleMinutes`

Type: `int`

Default: `120`

Description: Specifies the number of minutes of user inactivity before triggering idle actions, including turning off the display and, eventually, initiating a shutdown sequence. This value is used to configure timeouts for the `dpms off` action and the `check-and-shutdown` script.

## Detailed Configuration

When `local.caelestia-shell.enable` is set to `true`, the following configurations are applied:

### Package Installation

The following packages are installed to the user's home environment:

*   `nautilus`:  A file manager, typically used for browsing directories and managing files.
*   `pavucontrol`:  A volume control tool, used to manage audio inputs and outputs.
*   `celluloid`: A simple GTK+ frontend for mpv, used to play videos.
*   `kdePackages.networkmanager-qt`:  Network manager, used to manage network connections.
*   `checkAndShutdown`: A custom script (described below) that triggers a shutdown after a period of inactivity.

### `checkAndShutdown` Script

A shell script named `check-and-shutdown` is created using `pkgs.writeShellScriptBin`. This script performs the following actions:

1.  **Notification:** Sends a desktop notification using `libnotify` to warn the user that the system will shut down in 60 seconds due to inactivity. The notification includes an "Abort Shutdown" button.
2.  **Action Handling:** Checks if the user clicked the "Abort Shutdown" button. If so, it exits, preventing the shutdown.
3.  **Shutdown:** If the user does not abort the shutdown, it sleeps for 60 seconds and then initiates a system shutdown using `systemctl poweroff`.

### Caelestia Configuration

The `programs.caelestia` option is enabled and configured with specific settings:

*   `cli.enable = true;`: Enables the command-line interface for Caelestia.
*   `settings`: A nested attribute set defining various Caelestia settings:

    *   `appearance.rounding.scale = 0.8;`: Sets the rounding scale of UI elements.
    *   `appearance.transparency`: Configures transparency settings:
        *   `enabled = true;`: Enables transparency.
        *   `base = 0.95;`: Sets the base transparency level.
        *   `layers = 0.80;`: Sets the transparency level for layers.
    *   `general.apps`: Configures default applications:
        *   `terminal = [ "kitty" ];`: Sets the default terminal application to "kitty".
        *   `audio = [ "pavucontrol" ];`: Sets the default audio control application to "pavucontrol".
        *   `playback = [ "celluloid" ];`: Sets the default video playback application to "celluloid".
        *   `explorer = [ "nautilus" ];`: Sets the default file explorer to "nautilus".
    *   `general.idle`: Configures idle timeouts and actions:
        *   `timeouts`: A list of timeouts defining actions to perform after a period of inactivity.  The first timeout turns off the display after the time specified by `cfg.idleMinutes` multiplied by 60 (seconds), and turns it back on when the user returns. The second timeout, triggered 60 seconds later, runs the `check-and-shutdown` script, initiating the shutdown sequence.
    *   `background`: Configures background settings:
        *   `enabled = true;`: Enables background.
        *   `visualiser`: Configures the background visualiser:
            *   `enabled = true;`: Enables the visualiser.
            *   `autoHide = false;`: Prevents the visualiser from automatically hiding.
    *   `launcher.hiddenApps`: A list of applications to hide from the launcher. These applications are  `qt5ct`, `qt6ct`, `neovim`, `ranger`, `blueman-manager`, `blueman-adapters`, `mpv`, and `nixos-help`.
    *   `bar.status`: Configures the status bar:
        *   `showBattery = false;`: Hides battery status.
        *   `showAudio = true;`: Shows audio status.
        *   `showBluetooth = true;`: Shows bluetooth status.
        *   `showWifi = false;`: Hides wifi status.
    *   `bar.workspaces.shown = 3;`: Configures the number of workspaces shown.
    *   `bar.scrollAction`: Disables scroll actions on the bar for brightness, volume and workspaces
    *   `bar.tray.recolour = true;`: Enables tray icon recoloring.
    *   `osd.enableBrightness = false;`: Disables brightness OSD.
    *   `paths`: Configures paths for media assets:
        *   `"mediaGif"` = `"$HOME/.music.gif"`; Sets the path to the music GIF.
        *   `"sessionGif"` = `""`; Sets the path to the session GIF (empty string).
    *   `services.useFahrenheit = false;`: Disables fahrenheit.

### Local Variables

*   `local.variables.launcher`: Sets a local variable named `launcher` with the value `"caelestia shell drawers toggle launcher"`. This variable can be used to reference this string elsewhere in the configuration.

### Home Files

*   `home.file.".music.gif"`: Creates a symlink from `~/.music.gif` to `./media.gif`. This ensures that a specific media file is available in the user's home directory.
```
