{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.local.caelestia;
  checkAndShutdown = pkgs.writeShellScriptBin "check-and-shutdown" ''
    ACTION=$(${pkgs.libnotify}/bin/notify-send "Auto Shutdown" \
      "PC has been idle. Shuting down in 60 secondes." \
      --urgency=critical \
      --action="abort=Abort Shutdown")
    if [ "$ACTION" == "abort" ]; then 
      echo "Shutdown aborted by user."
      exit 0
    fi
    sleep 60
    systemctl poweroff
  '';
in
{
  options.local.caelestia = {
    enable = lib.mkEnableOption "Caelestia shell application";
    idleMinutes = lib.mkOption { type = lib.types.int; default = 120; description = "Minutes of idle"; };
  };

  config = lib.mkIf cfg.enable {

    home.packages = (with pkgs; [
      nautilus
      pavucontrol
      celluloid
      kdePackages.networkmanager-qt
    ]) ++ [
      checkAndShutdown
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
          playback = [ "celluloid" ];
          explorer = [ "nautilus" ];
        };
        general.idle = {
          timeouts = [
            {
              timeout = 2700;
              idleAction = "dpms off";
              returnAction = "dpms on";
            }
            {
              timeout = 2760;
              idleAction = "${checkAndShutdown}/bin/check-and-shutdown";
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
        launcher.hiddenApps = [ "qt5ct" "qt6ct" "neovim" "ranger" "blueman-manager" "blueman-adapters" "mpv" "nixos-help" ];
        bar.status = {
          showBattery = false;
          showAudio = true;
          showBluetooth = true;
          showWifi = false;
        };
        bar.workspaces.shown = 3;
        bar.scrollAction.brightness = false;
        bar.scrollAction.volume = false;
        bar.scrollAction.workspaces = false;
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
