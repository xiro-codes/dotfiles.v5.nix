{ pkgs, ... }:

let
  deps = with pkgs; [ hyprland jq bash procps ];
  binPath = pkgs.lib.makeBinPath deps;
  # Scripts logic extracted into discrete writeShellScriptBin calls
  hypr-workspace-set = pkgs.writeShellScriptBin "hypr-workspace-set" ''
    current=$(hyprctl activeworkspace -j | jq -r '.id')

    if [ $current -ge 1 ] && [ $current -le 3 ]; then
      current_set=0
    elif [ $current -ge 4 ] && [ $current -le 6 ]; then
      current_set=3
    elif [ $current -ge 7 ] && [ $current -le 9 ]; then
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

  hypr-move-to-set = pkgs.writeShellScriptBin "hypr-move-to-set" ''
    current=$(hyprctl activeworkspace -j | jq -r '.id')

    if [ $current -ge 1 ] && [ $current -le 3 ]; then
      current_set=0
    elif [ $current -ge 4 ] && [ $current -le 6 ]; then
      current_set=3
    elif [ $current -ge 7 ] && [ $current -le 9 ]; then
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

  hypr-switch-set = pkgs.writeShellScriptBin "hypr-switch-set" ''
    current=$(hyprctl activeworkspace -j | jq -r '.id')

    if [ $current -ge 1 ] && [ $current -le 3 ]; then
      case "$1" in
        next) target=$((current + 3)) ;;
        prev) target=$((current + 6)) ;;
        *) exit 1 ;;
      esac
    elif [ $current -ge 4 ] && [ $current -le 6 ]; then
      case "$1" in
        next) target=$((current + 3)) ;;
        prev) target=$((current - 3)) ;;
        *) exit 1 ;;
      esac
    elif [ $current -ge 7 ] && [ $current -le 9 ]; then
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
  # New Gaming Mode script for the isolated DP-3 monitor
  hypr-gaming-mode = pkgs.writeShellScriptBin "hypr-gaming-mode" ''
    
    if hyprctl monitors -j | jq -e '.[] | select(.name == "DP-3")' > /dev/null; then
        hyprctl keyword monitor "DP-3, disable"
        hyprctl keyword monitor "HDMI-A-1, 2560x1080@60, 0x0, 1"
        pkill -f steam
    else
        # Re-enables centered: 1920 wide centered over 2560 ( (2560-1920)/2 = 320 )
        hyprctl keyword monitor "DP-3, 1920x1080@60, 320x0, 1"
        hyprctl keyword monitor "HDMI-A-1, 2560x1080@60, 0x1080, 1"
        sleep 1
        steam -tenfoot &
    fi
  '';
in
pkgs.symlinkJoin {
  name = "hypr-tools";
  paths = [
    hypr-workspace-set
    hypr-move-to-set
    hypr-switch-set
    hypr-gaming-mode
  ];
}
