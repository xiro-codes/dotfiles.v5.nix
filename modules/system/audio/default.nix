{ config, lib, pkgs, ... }:

let
  cfg = config.local.audio;
in {
  options.local.audio = {
    enable = lib.mkEnableOption "PipeWire based audio stack";
  };

  config = lib.mkIf cfg.enable {
    # Remove PulseAudio if it was enabled elsewhere to avoid conflicts
    services.pulseaudio.enable = false;

    # Real-time kit for low-latency audio
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # Modern policy management
      wireplumber.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pulsemixer # CLI mixer
      pavucontrol # GUI mixer
      helvum # Patchbay for PipeWire
    ];
  };
}
