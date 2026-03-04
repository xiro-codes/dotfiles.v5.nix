# audio

This Nix module provides a convenient way to enable a modern, PipeWire-based audio stack on your system. It disables PulseAudio (if enabled elsewhere) to prevent conflicts, enables real-time scheduling for low-latency audio, and configures PipeWire with ALSA, PulseAudio, and JACK compatibility. Additionally, it installs several useful audio utilities.

## Options

### `local.audio.enable`

*   **Type:**  `boolean`
*   **Default:**  `false`

Enables the PipeWire-based audio stack. When set to `true`, the following actions are performed:

1.  **PulseAudio Removal:** If PulseAudio is enabled through other modules, it's disabled to avoid conflicts with PipeWire.  This is crucial as both systems manage audio devices, and running them concurrently will likely lead to issues.

2.  **Real-Time Kit (RTKit) Enablement:** The RTKit service is enabled. RTKit allows for real-time scheduling of audio processes, reducing latency and improving audio performance, particularly important for applications like music production or live performance.  Without RTKit, audio processes may be interrupted by other system tasks, leading to audio dropouts or glitches.

3.  **PipeWire Configuration:** The core of this module, this section configures PipeWire itself.

    *   `services.pipewire.enable = true;`: Enables the main PipeWire service.
    *   `services.pipewire.alsa.enable = true;`: Enables ALSA support within PipeWire. ALSA (Advanced Linux Sound Architecture) is the low-level audio driver framework in Linux. Enabling this allows PipeWire to use ALSA devices.
    *   `services.pipewire.alsa.support32Bit = true;`: Enables 32-bit ALSA support. Necessary for some older applications that still rely on 32-bit audio interfaces.  This ensures compatibility with a wider range of audio software.
    *   `services.pipewire.pulse.enable = true;`: Enables PulseAudio compatibility within PipeWire. This allows applications that expect PulseAudio to work seamlessly with PipeWire.  PipeWire effectively acts as a PulseAudio server, providing the same API to applications.
    *   `services.pipewire.jack.enable = true;`: Enables JACK (Jack Audio Connection Kit) support within PipeWire. JACK is a low-latency audio server popular in professional audio production. Enabling this allows PipeWire to be used as a JACK server, providing the same low-latency performance.
    *   `services.pipewire.wireplumber.enable = true;`: Enables WirePlumber, a modern session and policy manager for PipeWire.  WirePlumber replaces the older `pipewire-media-session` and provides more flexibility and control over audio routing and device configuration.  It allows you to define rules for how audio devices are handled, such as automatically routing audio from a specific application to a specific output.

4.  **Audio Utilities Installation:**  The following packages are added to the system's environment, providing useful audio tools.

    *   `pulsemixer`: A command-line mixer for PulseAudio (compatible with PipeWire's PulseAudio emulation).  It's useful for scripting audio adjustments or for users who prefer a terminal interface.

    *   `pavucontrol`: A GUI (Graphical User Interface) mixer for PulseAudio (compatible with PipeWire's PulseAudio emulation). It offers a graphical interface for controlling volume levels, input/output devices, and other audio settings.

    *   `helvum`: A patchbay for PipeWire.  Helvum allows you to graphically connect audio inputs and outputs, similar to a physical patchbay. This is extremely useful for complex audio routing setups and for visualizing the audio flow within your system.
