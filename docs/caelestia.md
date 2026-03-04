# Caelestia Module

This Nix module configures and enables the Caelestia shell application, providing a customized desktop experience. It manages dependencies, sets up application settings, configures idle behavior, and provides some quality-of-life improvements. It also sets up an auto-shutdown mechanism based on idle time.

## Options

Here's a breakdown of the available options within the `local.caelestia` scope:

*   **`local.caelestia.enable`**
    *   Type: `Boolean`
    *   Default: `false`
    *   Description: Enables or disables the Caelestia shell application. When enabled, this option activates all the configurations defined within the module, which includes installing necessary packages and configuring Caelestia settings.

*   **`local.caelestia.idleMinutes`**
    *   Type: `Integer`
    *   Default: `120`
    *   Description: Specifies the number of minutes of user inactivity before the system is considered idle. This value is used to trigger the auto-shutdown functionality.  Note that the actual auto-shutdown is hardcoded to 60 seconds after a notification pops up, as defined in the `checkAndShutdown` script.

## Configuration Details

When `local.caelestia.enable` is set to `true`, the module performs the following configurations:

*   **Package Installation:** Installs a set of essential desktop applications and tools:
    *   `nautilus`: The GNOME file manager.
    *   `pavucontrol`: A volume control tool for PulseAudio.
    *   `celluloid`: A simple GTK+ frontend for mpv.
    *   `kdePackages.networkmanager-qt`:  Network management tools from KDE.
    *   `checkAndShutdown`: A custom script that initiates a shutdown after a period of inactivity. This script sends a desktop notification allowing the user to abort the shutdown.

*   **Caelestia Shell Configuration (`programs.caelestia`):** Enables and customizes the Caelestia shell application.

    *   `enable = true;`: Enables the Caelestia shell.
    *   `package`:  Specifies the Caelestia shell package to use, overriding the default package to include extra runtime dependencies.  It ensures that the application has access to required libraries, such as `dconf`, `kdePackages.qt5compat`, and `kdePackages.networkmanager-qt`.
    *   `cli.enable = true;`: Enables the command-line interface for Caelestia.
    *   `settings`:  Defines various settings for the Caelestia shell, organized into sections:

        *   `appearance.rounding.scale = 0.8;`: Sets the rounding scale for the user interface elements.
        *   `appearance.transparency`:  Configures transparency for the Caelestia shell:
            *   `enabled = true;`: Enables transparency.
            *   `base = 0.95;`:  Sets the base transparency level.
            *   `layers = 0.80;`:  Sets the transparency level for layers.
        *   `general.apps`: Defines the default applications for various tasks:
            *   `terminal = [ "kitty" ];`: Sets the default terminal application to "kitty".
            *   `audio = [ "pavucontrol" ];`: Sets the default audio application to "pavucontrol".
            *   `playback = [ "celluloid" ];`: Sets the default playback application to "celluloid".
            *   `explorer = [ "nautilus" ];`: Sets the default file explorer to "nautilus".
        *   `general.idle`:  Configures idle behavior:
            *   `timeouts`: Defines a list of idle timeout actions.
                *   First timeout: `timeout = 2700; idleAction = "dpms off"; returnAction = "dpms on";` (45 minutes) turns the display off after 45 minutes of inactivity and on when activity is detected.
                *   Second timeout: `timeout = 2760; idleAction = "${checkAndShutdown}/bin/check-and-shutdown";` (46 minutes) executes the `check-and-shutdown` script after 46 minutes of inactivity.
        *   `background`: Configures background settings.
            *   `enabled = true;`: Enables background functionality.
            *   `visualiser`: Configures the background visualizer.
                *   `enabled = true;`: Enables the visualizer.
                *   `autoHide = false;`: Disables auto-hiding of the visualizer.
        *   `launcher.hiddenApps`:  Defines a list of applications to hide from the launcher.
        *   `bar.status`: Configures the status bar.
            *   `showBattery = false;`: Hides the battery status indicator.
            *   `showAudio = true;`: Shows the audio status indicator.
            *   `showBluetooth = true;`: Shows the Bluetooth status indicator.
            *   `showWifi = false;`: Hides the Wi-Fi status indicator.
        *   `bar.workspaces.shown`: Sets the number of workspaces to display on the bar to 3.
        *   `bar.scrollAction`: Disables scrolling actions on the bar for brightness, volume, and workspaces.
        *   `bar.tray.recolour = true;`: Enables recoloring of tray icons.
        *   `osd.enableBrightness = false;`: Disables on-screen display for brightness adjustments.
        *   `paths`:  Defines custom paths:
            *   `"mediaGif" = "$HOME/.music.gif";`: Sets the path for a media GIF file.
            *   `"sessionGif" = "";`: Sets the path for a session GIF file (empty by default).
        *   `services.useFahrenheit = false;`: Configures the application to use Celsius for temperature display.

*   **Local Variable:**
    *   `local.variables.launcher = "caelestia shell drawers toggle launcher";`:  Defines a local variable to be used in home-manager configuration (or elsewhere).

*   **Home File Configuration:** Creates a file named `.music.gif` in the home directory and sets its source to a local file named `media.gif` found within the same directory as the Nix configuration. This is likely used as a custom asset for Caelestia.

## `checkAndShutdown` Script Explanation

The `checkAndShutdown` script performs the following actions:

1.  **Desktop Notification:** Sends a desktop notification using `notify-send` (from the `libnotify` package) indicating that the computer will shut down in 60 seconds due to inactivity.
    *   The notification has an "abort" action, which allows the user to cancel the shutdown.
    *   The notification has "critical" urgency to ensure it is highly visible.

2.  **Action Check:** Checks the value returned by the notification action.  If the user clicks the "abort" button, the script exits.

3.  **Sleep:** Pauses execution for 60 seconds, giving the user a chance to abort the shutdown.

4.  **Shutdown:** If the script reaches this point (i.e., the user did not abort), it initiates a system shutdown using `systemctl poweroff`.

