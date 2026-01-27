{ pkgs, config, lib, ... }:
let
  cfg = config.local.mpd;
in
{
  options.local.mpd = {
    enable = lib.mkEnableOption "Enable mpd";
    path = lib.mkOption { type = lib.types.str; default = "/mnt/zima/Music"; };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.mpc pkgs.ymuse ];
    services.mpd-mpris.enable = true;
    services.mpd = {
      enable = true;
      musicDirectory = cfg.path;
      extraConfig = ''
          audio_output {
            type "pipewire"
              name "Pipewire"
          }
        audio_output {
          type "fifo"
            name "Visualizer"
            path "/tmp/mpd.fifo"
            format "44100:16:2"
        }
      '';
    };
    programs.ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };
      bindings = [
        {
          key = "j";
          command = "scroll_down";
        }
        {
          key = "k";
          command = "scroll_up";
        }
        {
          key = "J";
          command = [ "select_item" "scroll_down" ];
        }
        {
          key = "K";
          command = [ "select_item" "scroll_up" ];
        }
      ];
      settings = {
        execute_on_song_change = ''notify-send -i /tmp/.music_cover.png "Playing" "$(mpc --format '%title% - %album%' current)"'';
        visualizer_data_source = "/tmp/mpd.fifo";
        visualizer_output_name = "visualizer";
        visualizer_in_stereo = "yes";
        visualizer_type = "spectrum";
        visualizer_look = "+|";
      };

    };
  };
}
