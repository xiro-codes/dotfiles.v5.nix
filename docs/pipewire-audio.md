# pipewire-audio

This module provides a convenient way to enable a PipeWire-based audio stack on NixOS.  It handles disabling PulseAudio, enabling necessary PipeWire services, configuring ALSA, and installing supporting packages like wiremix. It aims to be a one-stop shop for setting up modern, low-latency audio using PipeWire.

## Options

This module exposes the following options under the `local.pipewire-audio` namespace:

### `local.pipewire-audio.enable`

Type:  Boolean

Default: `false`

Description:  Enables the PipeWire-based audio stack. When enabled, this option performs the following actions:

*   Disables the PulseAudio service if it's enabled elsewhere in your configuration. This avoids conflicts between PulseAudio and PipeWire. Note: This explicitly sets the PulseAudio service to disabled.

*   Enables the Real-Time Kit (rtkit) service, which is important for achieving low-latency audio performance. This allows audio processes to run with higher priority.

*   Configures and enables the `services.pipewire` options, including:

    *   `enable`:  Sets `services.pipewire.enable` to `true`, enabling the core PipeWire service.
    *   `alsa.enable`:  Sets `services.pipewire.alsa.enable` to `true`, enabling ALSA support within PipeWire. This allows PipeWire to interact with ALSA audio devices.
    *   `alsa.support32Bit`:  Sets `services.pipewire.alsa.support32Bit` to `false`. This disables 32-bit ALSA support within PipeWire.
    *   `pulse.enable`:  Sets `services.pipewire.pulse.enable` to `true`, enabling the PipeWire PulseAudio server. This provides a PulseAudio-compatible interface on top of PipeWire, allowing existing PulseAudio applications to work without modification.
    *   `jack.enable`:  Sets `services.pipewire.jack.enable` to `true`, enabling the PipeWire JACK server. This provides a JACK-compatible interface on top of PipeWire for use with professional audio applications.
    *   `wireplumber.enable`:  Sets `services.pipewire.wireplumber.enable` to `true`, enabling WirePlumber. WirePlumber is a session and policy manager for PipeWire, responsible for managing connections between audio devices and applications, as well as applying configuration policies.  It's a crucial component for a functional PipeWire setup.

*   Adds the `wiremix` package to `environment.systemPackages`. Wiremix is a graphical mixer and volume control application for PipeWire.

## Usage Example

To enable the PipeWire audio stack, add the following to your `configuration.nix`:

```nix
{
  imports = [
    ./your-pipewire-module.nix  # Replace with the actual path to this module
  ];

  local.pipewire-audio.enable = true;
}
```

This will disable PulseAudio, enable rtkit, and configure PipeWire with ALSA, PulseAudio, JACK, and WirePlumber support. It will also install the `wiremix` utility.
