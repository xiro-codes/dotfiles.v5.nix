{ config, lib, pkgs, ... }:

let
  cfg = config.local.bluetooth;
in {
  options.local.bluetooth = {
    enable = lib.mkEnableOption "Modern Bluetooth stack with PipeWire integration";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      # Enables experimental features like battery level reporting for peripherals
      settings = {
        General = {
          Experimental = true;
          # Enables fast connection for modern devices
          FastConnectable = true;
        };
      };
    };

    # Modern Bluetooth requires PipeWire for the best audio experience
    services.pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      # Bluetooth-specific PipeWire settings
      wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hfp_ag" ];
        };
      };
    };

    # Blueman provides the graphical tray applet and manager
    services.blueman.enable = true;

    # Helpful tools for the CLI
    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
    ];
  };
}
