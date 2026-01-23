{ config, lib, pkgs, ... }:

let
  cfg = config.local.bluetooth;
  # Check if the audio module is enabled elsewhere in the system config
  audioEnabled = config.local.audio.enable or false;
in {
  options.local.bluetooth = {
    enable = lib.mkEnableOption "Modern Bluetooth stack";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
        FastConnectable = true;
      };
    };

    services.blueman.enable = true;

    # If audio is enabled, we tell WirePlumber to use high-quality Bluetooth codecs
    services.pipewire.wireplumber.extraConfig = lib.mkIf audioEnabled {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hfp_ag" ];
      };
    };
  };
}
