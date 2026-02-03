{ config, lib, pkgs, ... }:

let
  cfg = config.local;
  isDefaultShell = (config.osConfig.users.users.${config.home.username}.shell or null) == pkgs.fish;
in
{
  options.local = {
    # Fish shell
    fish = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = isDefaultShell;
        description = "Enable fish config if it is the system shell.";
      };
    };

    # Kitty terminal
    kitty = {
      enable = lib.mkEnableOption "Kitty terminal emulator with custom configuration";
    };

    # Waybar status bar
    waybar = {
      enable = lib.mkEnableOption "Waybar status bar for Wayland compositors";
    };

    # Hyprlauncher
    hyprlauncher = {
      enable = lib.mkEnableOption "Hyprlauncher, the native Hyprland application launcher";
    };

    # Hyprpaper
    hyprpaper = {
      enable = lib.mkEnableOption "Hyprpaper, the native Hyprland wallpaper daemon";
      wallpapers = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = "List of wallpaper paths to preload for Hyprpaper";
      };
    };

    # Mako notification daemon
    mako = {
      enable = lib.mkEnableOption "Mako notification daemon for Wayland";
    };

    # Ranger file manager
    ranger = {
      enable = lib.mkEnableOption "Ranger terminal-based file manager with devicons support";
    };

    # MPD music player daemon
    mpd = {
      enable = lib.mkEnableOption "MPD (Music Player Daemon) with ncmpcpp client";
      path = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/zima/Music";
        description = "Path to the music directory for MPD to serve";
      };
    };

    # Caelestia configuration
    caelestia = {
      colorScheme = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Color scheme name for Caelestia (e.g., 'gruvbox', 'catppuccin'). If null, uses dynamic wallpaper colors.";
      };
    };
  };

  config = lib.mkMerge [
    # Fish
    (lib.mkIf cfg.fish.enable {
      programs.eza.enable = true;
      programs.zoxide.enable = true;
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set -g fish_greeting ""
          zoxide init fish | source
          #cat $HOME/.local/state/caelestia/sequences.txt 2>/dev/null 
        '';
        shellAbbrs = {
          ls = "eza --icons always";
          cd = "z";
          lsa = "eza --icons always --all";
          lsl = "eza --icons always -al";
          du = "dust";
          df = "duf";
        };
      };
    })

    # Kitty
    (lib.mkIf cfg.kitty.enable {
      local.variables.terminal = "kitty";
      programs.kitty = {
        enable = true;
        extraConfig = ''
          window_padding_width 5
        '';
      };
    })

    # Waybar
    (lib.mkIf cfg.waybar.enable {
      home.packages = with pkgs; [ pavucontrol jq wttrbar ];
      programs.waybar = {
        enable = true;
        systemd = {
          enable = true;
          target = "hyprland-session.target";
        };
        settings = pkgs.callPackage ../waybar/settings.nix { inherit pkgs cfg; };
      };
    })

    # Hyprlauncher
    (lib.mkIf cfg.hyprlauncher.enable {
      home.packages = with pkgs; [ hyprlauncher ];
      local.variables.launcher = "hyprlauncher";
    })

    # Hyprpaper
    (lib.mkIf cfg.hyprpaper.enable {
      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = "on";
          preload = map (p: "${p}") cfg.hyprpaper.wallpapers;
          wallpaper = [ ",${builtins.elemAt cfg.hyprpaper.wallpapers 0}" ];
        };
      };
      local.variables.wallpaper = "hyprpaper";
    })

    # Mako
    (lib.mkIf cfg.mako.enable {
      services.mako = {
        enable = true;
        padding = "15";
        borderSize = 2;
        borderRadius = 5;
      };
    })

    # Ranger
    (lib.mkIf cfg.ranger.enable {
      home.packages = with pkgs; [ ranger p7zip unzip ];
      local.variables.fileManager = "ranger";
      xdg.configFile = {
        "ranger/rifle.conf".source = ../ranger/rifle.conf;
        "ranger/rc.conf".source = ../ranger/rc.conf;
        "ranger/plugins/ranger_devicons".source = ../ranger/ranger_devicons;
      };
    })

    # MPD
    (lib.mkIf cfg.mpd.enable {
      home.packages = [ pkgs.mpc pkgs.ymuse ];
      services.mpd-mpris.enable = true;
      services.mpd = {
        enable = true;
        musicDirectory = cfg.mpd.path;
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
          { key = "j"; command = "scroll_down"; }
          { key = "k"; command = "scroll_up"; }
          { key = "J"; command = [ "select_item" "scroll_down" ]; }
          { key = "K"; command = [ "select_item" "scroll_up" ]; }
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
    })
  ];
}
