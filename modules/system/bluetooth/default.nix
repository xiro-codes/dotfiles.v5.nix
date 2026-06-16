{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.local.bluetooth;
  # Check if the audio module is enabled elsewhere in the system config
  audioEnabled = config.local.pipewire-audio.enable;
  plasmaEnabled = config.services.desktopManager.plasma6.enable;
in
{
  options.local.bluetooth = {
    enable = mkEnableOption "Modern Bluetooth stack";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
        FastConnectable = true;
        JustWorksRepairing = "always";
        Privacy = "device";
        ControllerMode = "dual";
      };
    };

    services.blueman.enable = mkIf (!plasmaEnabled) true;
    environment.systemPackages = [ pkgs.overskride ];
    # If audio is enabled, we tell WirePlumber to use high-quality Bluetooth codecs
    services.pipewire.wireplumber.extraConfig = mkIf audioEnabled {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "bap_sink"
          "bap_source"
          "hsp_hs"
          "hfp_ag"
        ];
      };
    };
  };
}
