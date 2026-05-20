{ pkgs, ... }:
let
  deps = with pkgs; [
    hyprland
    jq
    bash
    procps
  ];
  binPath = pkgs.lib.makeBinPath deps;
  # Scripts logic extracted into discrete writeShellApplication calls
  hypr-workspace-set = pkgs.writeShellApplication {
    name = "hypr-workspace-set";
    text = ''
      current=$(hyprctl activeworkspace -j | jq -r '.id')

      if [ "$current" -ge 1 ] && [ "$current" -le 3 ]; then
        current_set=0
      elif [ "$current" -ge 4 ] && [ "$current" -le 6 ]; then
        current_set=3
      elif [ "$current" -ge 7 ] && [ "$current" -le 9 ]; then
        current_set=6
      else
        current_set=0
      fi

      case "$1" in
        u) offset=1 ;;
        i) offset=2 ;;
        o) offset=3 ;;
        *) exit 1 ;;
      esac

      target=$((current_set + offset))
      hyprctl dispatch workspace $target
    '';
  };

  hypr-move-to-set = pkgs.writeShellApplication {
    name = "hypr-move-to-set";
    text = ''
      current=$(hyprctl activeworkspace -j | jq -r '.id')

      if [ "$current" -ge 1 ] && [ "$current" -le 3 ]; then
        current_set=0
      elif [ "$current" -ge 4 ] && [ "$current" -le 6 ]; then
        current_set=3
      elif [ "$current" -ge 7 ] && [ "$current" -le 9 ]; then
        current_set=6
      else
        current_set=0
      fi

      case "$1" in
        u) offset=1 ;;
        i) offset=2 ;;
        o) offset=3 ;;
        *) exit 1 ;;
      esac

      target=$((current_set + offset))
      hyprctl dispatch movetoworkspace $target
    '';
  };

  hypr-switch-set = pkgs.writeShellApplication {
    name = "hypr-switch-set";
    text = ''
      current=$(hyprctl activeworkspace -j | jq -r '.id')

      if [ "$current" -ge 1 ] && [ "$current" -le 3 ]; then
        case "$1" in
          next) target=$((current + 3)) ;;
          prev) target=$((current + 6)) ;;
          *) exit 1 ;;
        esac
      elif [ "$current" -ge 4 ] && [ "$current" -le 6 ]; then
        case "$1" in
          next) target=$((current + 3)) ;;
          prev) target=$((current - 3)) ;;
          *) exit 1 ;;
        esac
      elif [ "$current" -ge 7 ] && [ "$current" -le 9 ]; then
        case "$1" in
          next) target=$((current - 6)) ;;
          prev) target=$((current - 3)) ;;
          *) exit 1 ;;
        esac
      else
        target=1
      fi

      hyprctl dispatch workspace $target
    '';
  };
  # New Gaming Mode script for the isolated DP-3 monitor
  hypr-gaming-mode = pkgs.writeShellApplication {
    name = "hypr-gaming-mode";
    text = ''

      if hyprctl monitors -j | jq -e '.[] | select(.name == "DP-3")' > /dev/null; then
          hyprctl keyword monitor "DP-3, disable"
          hyprctl keyword monitor "HDMI-A-1, 2560x1080@60, 0x0, 1"
      else
          hyprctl keyword monitor "DP-3, 1920x1080@60, 0x0, 1"
          hyprctl keyword monitor "HDMI-A-1, disable"
      fi
    '';
  };

  hypr-layout-toggle = pkgs.writeShellApplication {
    name = "hypr-layout-toggle";
    text = ''
      current_layout=$(hyprctl getoption general:layout -j | jq -r '.str')

      if [ "$current_layout" = "scrolling" ]; then
        hyprctl keyword general:layout "master"
      else
        hyprctl keyword general:layout "scrolling"
      fi
    '';
  };
in
pkgs.symlinkJoin {
  name = "hypr-tools";
  paths = [
    hypr-workspace-set
    hypr-move-to-set
    hypr-switch-set
    hypr-gaming-mode
    hypr-layout-toggle
  ];
}
