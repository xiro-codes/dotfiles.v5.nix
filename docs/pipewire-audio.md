```markdown
# pipewire-audio

This module provides a convenient way to enable a PipeWire-based audio stack on NixOS. It disables PulseAudio (if enabled elsewhere) to avoid conflicts, configures PipeWire with ALSA, PulseAudio, and JACK support, and installs common audio utilities like `pulsemixer` and `pavucontrol`.  It also sets up rtkit for low-latency audio.

## Options

### `local.pipewire-audio.enable`

_(Type: boolean, Default: `false`)_

Enables the PipeWire-based audio stack.  When enabled, this option performs the following actions:

*   Disables the PulseAudio service (if it was enabled elsewhere). This is crucial to prevent conflicts between the two audio servers. If you're having audio issues after enabling this module, double check that PulseAudio is fully disabled.
*   Enables Real-Time Kit (`rtkit`) to prioritize audio threads, resulting in lower latency. This is particularly beneficial for musicians, audio engineers, and anyone who needs responsive audio.
*   Enables the `pipewire` service with several sub-options:
    *   `alsa.enable = true`: Enables ALSA (Advanced Linux Sound Architecture) support within PipeWire. This allows PipeWire to interact with your sound card and other ALSA devices.
    *   `alsa.support32Bit = true`: Enables 32-bit ALSA support. This is necessary for some older applications that rely on 32-bit audio libraries.
    *   `pulse.enable = true`: Enables PulseAudio support within PipeWire. This allows applications that are designed to use PulseAudio to seamlessly work with PipeWire.  This creates a compatibility layer, so most applications should "just work" even if they haven't been specifically adapted for PipeWire.
    *   `jack.enable = true`: Enables JACK (JACK Audio Connection Kit) support within PipeWire. JACK is a low-latency audio server commonly used in professional audio production.
    *   `wireplumber.enable = true`: Enables WirePlumber, a modern session and policy manager for PipeWire. WirePlumber replaces the older `pipewire-media-session` and offers more flexible and configurable audio routing and policy management.  It's highly recommended to use WirePlumber for a more modern PipeWire experience.
*   Installs `pulsemixer` (a command-line mixer), and `pavucontrol` (PulseAudio Volume Control, a graphical mixer) which, despite the name, works well with PipeWire's PulseAudio compatibility layer. These tools provide a convenient way to control volume levels, input/output devices, and other audio settings.

**Example:**

To enable the PipeWire audio stack, add the following to your `configuration.nix`:

```nix
{
  local.pipewire-audio.enable = true;
}
```

**Troubleshooting:**

*   **No audio after enabling:** Ensure that `services.pulseaudio.enable = false;` is set in your configuration (either explicitly or implicitly through another module). Also, make sure your user is added to the `audio` group.

*   **JACK applications not working:**  Verify that the JACK server is running correctly within PipeWire. You may need to configure JACK settings using a JACK control panel (e.g., `qjackctl`).

*   **Configuration:**  WirePlumber provides flexible configuration. Check `/etc/pipewire/wireplumber.conf.d/` for configuration snippets you can adapt.
```
