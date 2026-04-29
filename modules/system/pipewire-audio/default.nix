{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.local.pipewire-audio;
in
{
  options.local.pipewire-audio = {
    enable = mkEnableOption "PipeWire based audio stack";
  };

  config = mkIf cfg.enable {
    # Remove PulseAudio if it was enabled elsewhere to avoid conflicts
    services.pulseaudio.enable = false;

    # Real-time kit for low-latency audio
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = lib.mkForce false;
      pulse.enable = true;
      jack.enable = true;

      # Modern policy management
      wireplumber.enable = true;
    };

    environment.systemPackages = with pkgs; [
      wiremix
    ];
  };
}
