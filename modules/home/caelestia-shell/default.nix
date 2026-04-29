{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.local.caelestia-shell;
in
{
  options.local.caelestia-shell = {
    enable = mkEnableOption "Caelestia shell application";
  };

  config = mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        nautilus
        pavucontrol
        celluloid
        kdePackages.networkmanager-qt
      ]);
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
          playback = [ "celluloid" ];
          explorer = [ "nautilus" ];
        };
        general.idle = {
          timeouts = [
            {
              timeout = 1800; # Shortened for testing
              idleAction = "dpms off";
              returnAction = "dpms on";
            }
            {
              timeout = 5400; # Shortened for testing
              idleAction = "exec shutdown +1";
              returnAction = "exec shutdown -c";
            }
          ];
        };
        background = {
          enabled = true;
          visualiser = {
            enabled = true;
            autoHide = false;
          };
        };
        launcher.hiddenApps = [
          "qt5ct"
          "qt6ct"
          "neovim"
          "blueman-manager"
          "blueman-adapters"
          "mpv"
          "nixos-help"
        ];
        bar.status = {
          showBattery = false;
          showAudio = true;
          showBluetooth = true;
          showWifi = false;
        };
        bar.workspaces.shown = 3;
        bar.tray.recolour = true;
        osd.enableBrightness = false;

        paths = {
          "mediaGif" = "$HOME/.music.gif";
          "sessionGif" = "";
        };
        services.useFahrenheit = false;
      };
    };
    local.variables.launcher = "caelestia shell drawers toggle launcher";
    home.file.".music.gif".source = ./media.gif;
  };
}
