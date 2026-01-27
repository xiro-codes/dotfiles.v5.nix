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
      nautilus
      pavucontrol
      mpv
    ];
    programs.caelestia = {
      enable = true;

      cli.enable = true;
      settings = {
        appearance.rounding.scale = 0.8;
        appearance.transparency = {
          enabled = true;
          base = 0.95;
          layers = 0.80;
        };
        general.apps = {
          terminal = [ "kitty" ];
          audio = [ "pavucontrol" ];
          playback = [ "mpv" ];
          explorer = [ "nautilus" ];
        };
        background.enabled = true;
        background.visualizer = {
          enabled = true;
          autoHide = false;
        };
        launcher.hiddenApps = [ "Qt5 Settings" "Qt6 Settings" "Neovim wrapper" "ranger" "blueman-manager" "blueman-adapters" "mpv" "NixOS Manual" ];
        bar.status = {
          showBattery = false;
          showAudio = true;
          showBluetooth = true;
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
