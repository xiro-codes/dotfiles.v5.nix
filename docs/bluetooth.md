# bluetooth

This module enables and configures a modern Bluetooth stack for NixOS. It sets up the necessary hardware configurations, automatically powers on Bluetooth at boot, and applies various settings to enhance the Bluetooth experience. It also integrates with audio and desktop environment settings to provide a seamless user experience. Specifically, when audio is enabled through the `local.audio.enable` option, it configures WirePlumber to utilize high-quality Bluetooth codecs. If Plasma is not the selected desktop, it also enables Blueman.

## Options

This module provides the following options:

### `local.bluetooth.enable`

Type: boolean

Default value: `false`

Description: Enables the modern Bluetooth stack. Setting this to `true` activates the configurations defined within the module, enabling Bluetooth functionality and applying the specified settings.

## Configuration Details

When `local.bluetooth.enable` is set to `true`, the following configurations are applied:

*   **Hardware Configuration:**
    *   `hardware.bluetooth.enable` is set to `true`, enabling the Bluetooth hardware.
    *   `hardware.bluetooth.powerOnBoot` is set to `true`, ensuring Bluetooth is automatically powered on during system startup.
    *   `hardware.bluetooth.settings.General` is configured with the following options:
        *   `Experimental = true`: Enables experimental Bluetooth features.
        *   `FastConnectable = true`: Allows for faster connection establishment with paired devices.
        *   `JustWorksRepairing = "always"`: Configures automatic pairing repair when using the "Just Works" pairing method.
        *   `Privacy = "device"`: Sets the Bluetooth privacy mode to "device", which may prevent the device from being discoverable by default.
        *   `ControllerMode = "dual"`: Sets the Bluetooth controller mode to "dual", allowing for simultaneous BR/EDR and LE connections.

*   **Blueman Integration:**
    *   If Plasma 6 is not enabled via `config.services.desktopManager.plasma6.enable`, `services.blueman.enable` is set to `true`. Blueman provides a graphical interface for managing Bluetooth devices.

*   **Audio Integration (with PipeWire/WirePlumber):**
    *   If `config.local.audio.enable` is `true` (audio is enabled elsewhere in the system configuration), the following WirePlumber settings are applied:
        *   `services.pipewire.wireplumber.extraConfig."monitor.bluez.properties"` is configured to:
            *   `"bluez5.enable-sbc-xq" = true`: Enables the SBC XQ Bluetooth audio codec for improved audio quality.
            *   `"bluez5.enable-msbc" = true`: Enables the mSBC Bluetooth audio codec.
            *   `"bluez5.enable-hw-volume" = true`: Enables hardware volume control via Bluetooth.
            *   `"bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hfp_ag" ]`: Configures the supported Bluetooth roles for audio devices, covering a wide range of use cases.
                *   `a2dp_sink`:  Allows the device to receive high-quality audio (e.g., headphones).
                *   `a2dp_source`: Allows the device to transmit high-quality audio (e.g., streaming music).
                *   `bap_sink`: Allows the device to receive broadcast audio (e.g., hearing aids).
                *   `bap_source`: Allows the device to transmit broadcast audio (e.g., assistive listening devices).
                *   `hsp_hs`:  Headset Profile (e.g., simple headsets).
                *   `hfp_ag`: Hands-Free Profile (e.g., car kits).

This configuration ensures that the Bluetooth stack is properly initialized, audio quality is maximized (when audio is enabled), and a user-friendly interface is available for managing Bluetooth devices.
