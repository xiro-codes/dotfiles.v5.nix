```markdown
# caelestia-shell

This Nix module configures the Caelestia shell environment, providing a collection of applications, settings, and configurations to enhance the user experience. It includes options for enabling the shell, setting idle timeout durations, managing application settings, and customizing the appearance of the environment.

## Options

### `local.caelestia-shell.enable`

Type: `boolean`

Default: `false`

Description: Enables the Caelestia shell application. When enabled, this option activates the configurations defined within the module, setting up the environment with specified packages, settings, and customizations.  This is the main switch to turn caelestia on or off.

### `local.caelestia-shell.idleMinutes`

Type: `int`

Default: `120`

Description: Specifies the number of minutes of user idle time before certain actions are triggered, such as power saving or system shutdown. This value is used to configure the idle timeout settings for the Caelestia environment. It influences how long the system waits for user activity before executing idle-related commands. The value is defined in minutes.

## Configuration Details

When `local.caelestia-shell.enable` is set to `true`, the following configurations are applied:

### `home.packages`

A list of packages is installed into the user's home environment. This includes:

*   `nautilus`: The GNOME file manager.
*   `pavucontrol`: A PulseAudio volume control tool.
*   `celluloid`: A simple GTK+ based media player frontend for mpv.
*   `kdePackages.networkmanager-qt`: KDE's network manager Qt frontend.
*   `checkAndShutdown`: A custom script (defined within the module) that handles automatic shutdown after a period of inactivity. It sends a notification and allows the user to abort the shutdown process.

### `programs.caelestia`

Configuration for the Caelestia application itself:

*   `enable`: Enables the Caelestia program.
*   `cli.enable`: Enables the Caelestia command-line interface.
*   `settings`: A detailed set of settings for customizing Caelestia's behavior and appearance.  These settings cover a wide range of aspects of the user experience.

    *   `appearance.rounding.scale`: A floating-point value determining the rounding radius applied to UI elements, set to `0.8`.

    *   `appearance.transparency`: Settings related to transparency effects.

        *   `enabled`: A boolean determining whether transparency effects are enabled, set to `true`.

        *   `base`: A floating-point value determining the base transparency level, set to `0.95`.  This is the default transperancy.

        *   `layers`: A floating-point value determining the transparency level of layers within the UI, set to `0.80`.

    *   `general.apps`: Configures default applications for various tasks.

        *   `terminal`: A list containing the preferred terminal application, set to `["kitty"]`.

        *   `audio`: A list containing the preferred audio control application, set to `["pavucontrol"]`.

        *   `playback`: A list containing the preferred media playback application, set to `["celluloid"]`.

        *   `explorer`: A list containing the preferred file explorer application, set to `["nautilus"]`.

    *   `general.idle`: Configuration related to handling idle states.  This is where the `idleMinutes` settings come into play indirectly.

        *   `timeouts`: A list of timeout configurations.

            *   The first timeout is set to 2700 seconds (45 minutes), triggering DPMS (Display Power Management Signaling) to turn the monitor off (`idleAction = "dpms off"`) and on (`returnAction = "dpms on"`) when the user returns.

            *   The second timeout is set to 2760 seconds (46 minutes), triggering the `checkAndShutdown` script to initiate the shutdown process.

    *   `background`: Configuration for background related settings.

        *   `enabled`: Enables background configuration.

        *   `visualiser`: Configuration for the background audio visualizer.

            *   `enabled`: Enables the background audio visualizer.

            *   `autoHide`: Disables auto-hiding of the visualizer (set to `false`).

    *   `launcher.hiddenApps`: A list of applications to hide from the launcher, including `qt5ct`, `qt6ct`, `neovim`, `ranger`, `blueman-manager`, `blueman-adapters`, `mpv`, and `nixos-help`.

    *   `bar.status`: Configuration for the status bar.

        *   `showBattery`: Disables showing battery status (`false`).

        *   `showAudio`: Enables showing audio status (`true`).

        *   `showBluetooth`: Enables showing Bluetooth status (`true`).

        *   `showWifi`: Disables showing Wi-Fi status (`false`).

    *   `bar.workspaces.shown`: Sets the number of visible workspaces in the bar to `3`.

    *   `bar.scrollAction`: Disables scroll actions for brightness, volume and workspaces

        *   `brightness`: disables brightness
        *   `volume`: disables volume
        *   `workspaces`: disables workspaces

    *   `bar.tray.recolour`: Enables recoloring of tray icons (`true`).

    *   `osd.enableBrightness`: Disables the on-screen display for brightness changes (`false`).

    *   `paths`: Configuration for custom paths.

        *   `"mediaGif"`: Specifies the path to a GIF file used for media notifications (set to `$HOME/.music.gif`).

        *   `"sessionGif"`: Specifies the path to a GIF file used for session-related events (set to `""`, empty string).

    *   `services.useFahrenheit`: Disables the use of Fahrenheit for temperature display, implicitly using Celsius (`false`).

### `local.variables.launcher`

Defines a local variable named `launcher` with the value `"caelestia shell drawers toggle launcher"`. This variable can be used within the configuration or scripts to refer to the launcher command.

### `home.file.\".music.gif\"`

Copies the local file `./media.gif` to the user's home directory as `.music.gif`.  This is used for media notifications.

## `checkAndShutdown` script

This script is created as a binary using `pkgs.writeShellScriptBin` and is located at `${checkAndShutdown}/bin/check-and-shutdown`.

It uses `notify-send` to display a critical notification indicating that the system will shut down in 60 seconds due to inactivity. The notification includes an "Abort Shutdown" action.

If the user clicks the "Abort Shutdown" action, the script exits, preventing the shutdown. Otherwise, it waits for 60 seconds and then uses `systemctl poweroff` to shut down the system.

```
ACTION=$(${pkgs.libnotify}/bin/notify-send \"Auto Shutdown\" \\
  \"PC has been idle. Shuting down in 60 secondes.\" \\
  --urgency=critical \\
  --action=\"abort=Abort Shutdown\")

if [ \"$ACTION\" == \"abort\" ]; then
   echo \"Shutdown aborted by user.\"
  exit 0
fi

sleep 60
systemctl poweroff
```

