# bluetooth

This module configures a modern Bluetooth stack, enabling Bluetooth support, setting power-on behavior, and applying various quality-of-life settings.  It also integrates with PipeWire for improved audio codec support when audio is enabled via the `local.pipewire-audio` module. Additionally, it handles the installation of necessary packages and the activation of the `blueman` service if Plasma is not being used as the desktop environment.

## Options

This module provides the following options:

### `local.bluetooth.enable`

*   **Type:** boolean
*   **Default:** `false`
*   **Description:** Enables the modern Bluetooth stack, configuring Bluetooth hardware, services, and settings. This option is the primary switch for activating all Bluetooth-related features provided by this module.

## Configuration Details

When `local.bluetooth.enable` is set to `true`, the following configurations are applied:

*   **Bluetooth Hardware:**
    *   `hardware.bluetooth.enable` is set to `true`, enabling Bluetooth support at the hardware level.
    *   `hardware.bluetooth.powerOnBoot` is set to `true`, ensuring Bluetooth is powered on at boot.
    *   `hardware.bluetooth.settings.General` is configured with several options for an improved user experience:
        *   `Experimental = true`: Enables experimental features (use with caution).
        *   `FastConnectable = true`: Enables faster connection times to previously paired devices.
        *   `JustWorksRepairing = "always"`: Automatically repairs "Just Works" pairing issues (devices that pair without a PIN).
        *   `Privacy = "device"`: Sets the Bluetooth privacy mode to "device," providing a good balance between discoverability and privacy.
        *   `ControllerMode = "dual"`: Sets the Bluetooth controller mode to "dual"

*   **Blueman Service:** If Plasma 6 is not enabled (i.e., `config.services.desktopManager.plasma6.enable` is `false`), the `blueman` service (`services.blueman.enable = true;`) is enabled, providing a graphical Bluetooth management interface.  This is useful for desktop environments that don't have built-in Bluetooth management tools.

*   **System Packages:** The `overskride` package (`pkgs.overskride`) is added to `environment.systemPackages`. This package likely provides additional Bluetooth-related tools or utilities.  Without knowing more about `overskride`, it's safe to assume it enhances the overall Bluetooth experience.

*   **PipeWire Integration (if audio is enabled):**  If the `local.pipewire-audio.enable` option is enabled, then WirePlumber is configured with properties to enhance Bluetooth audio quality. This is done through `services.pipewire.wireplumber.extraConfig`:

    *   `"bluez5.enable-sbc-xq" = true`: Enables the SBC XQ (SBC eXtra Quality) codec for potentially higher-quality audio using the standard SBC codec.
    *   `"bluez5.enable-msbc" = true`: Enables the mSBC codec which is frequently used for headsets as it provides better audio quality for headset profiles than the standard SBC codec.
    *   `"bluez5.enable-hw-volume" = true`: Enables hardware volume control for Bluetooth devices, allowing the volume to be adjusted directly on the device or through the system's volume controls.
    *   `"bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hfp_ag" ]`: Explicitly enables various Bluetooth profiles. These roles define the capabilities of the Bluetooth device:
        *   `a2dp_sink`: Allows the device to receive high-quality audio (e.g., playing music from a phone on Bluetooth speakers).
        *   `a2dp_source`: Allows the device to transmit high-quality audio (e.g., streaming music from a computer to Bluetooth headphones).
	    *	`bap_sink`: Bluetooth Audio Profile sink
	    *	`bap_source`: Bluetooth Audio Profile source
        *   `hsp_hs`: Headset Profile - Headset
        *   `hfp_ag`: Hands-Free Profile - Audio Gateway (e.g., a phone or computer acting as the audio source)
