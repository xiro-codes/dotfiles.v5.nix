{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.local.caelestia;
in
{
  options.local.caelestia = {
    enable = lib.mkEnableOption "Caelestia shell application";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      pavucontrol
      celluloid
      kdePackages.networkmanager-qt
    ];
    programs.caelestia = {
      enable = true;
      package = inputs.caelestia-shell.packages.x86_64-linux.default.override {
        extraRuntimeDeps = with pkgs; [
          dconf
          kdePackages.qt5compat
          kdePackages.networkmanager-qt
        ];
      };
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
