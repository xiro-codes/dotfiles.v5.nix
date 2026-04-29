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
  checkAndShutdown = pkgs.writeShellScriptBin "check-and-shutdown" ''
    # Turn screen back on so the user can see the notification
    hyprctl dispatch dpms on
    
    # Schedule shutdown in 1 minute
    shutdown +1
    
    ACTION=$(${pkgs.libnotify}/bin/notify-send "Auto Shutdown" \
      "PC has been idle. Shutting down in 60 seconds." \
      --urgency=critical \
      --action="abort=Abort Shutdown")
      
    if [ "$ACTION" == "abort" ]; then
      shutdown -c
      ${pkgs.libnotify}/bin/notify-send "Auto Shutdown" "Shutdown aborted by user."
      echo "Shutdown aborted by user."
      exit 0
    fi
  '';
in
{
  options.local.caelestia-shell = {
    enable = mkEnableOption "Caelestia shell application";
    idleMinutes = mkOption {
      type = types.int;
      default = 120;
      description = "Minutes of idle";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        nautilus
        pavucontrol
        celluloid
        kdePackages.networkmanager-qt
      ])
      ++ [
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
              timeout = 10; # Shortened for testing
              idleAction = "dpms off";
              returnAction = "dpms on";
            }
            {
              timeout = 20; # Shortened for testing
              idleAction = "shutdown +2";
              returnAction = "shutdown -c";
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
