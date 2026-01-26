{ config, lib, pkgs, ... }:

let
  cfg = config.local.shell;
in
{
  options.local.shell = {
    enable = lib.mkEnableOption "shell module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pcmanfm
      pavucontrol
      mpv
    ];
    programs.caelestia = {
      enable = true;

      cli.enable = true;
      settings = {
        general.apps = {
          terminal = [ "kitty" ];
          audio = [ "pavucontrol" ];
          playback = [ "mpv" ];
          explorer = [ "pcmanfm" ];
        };
        bar.status = {
          showBattery = false;
          showAudio = true;
          showBluetooth = false;
          showWifi = false;
        };
        bar.workspaces.shown = 3;
        bar.scrollAction.brightness = false;
        osd.enableBrightness = false;
        paths = {
          "mediaGif" = "";
          "sessionGif" = "";
        };
        services.useFahrenheit = false;
      };
    };
    local.variables.launcher = "caelestia shell drawers toggle launcher";
  };
}
