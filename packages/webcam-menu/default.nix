{ pkgs, lib, ... }:
let
  inherit (lib) getExe generators;
  
  webcam-move = pkgs.writeShellApplication {
    name = "webcam-move";
    runtimeInputs = with pkgs; [ jq hyprland ];
    text = ''
      POS=$1
      MONITOR=$(hyprctl monitors -j | jq -c '.[] | select(.focused)')
      MON_W=$(echo "$MONITOR" | jq -r '.width')
      MON_H=$(echo "$MONITOR" | jq -r '.height')
      
      # Set dimensions matching window rules + margin
      WIN_W=320
      WIN_H=240
      MARGIN=20
      
      case $POS in
        tl)
          X=$MARGIN
          Y=$MARGIN
          ;;
        tr)
          X=$((MON_W - WIN_W - MARGIN))
          Y=$MARGIN
          ;;
        bl)
          X=$MARGIN
          Y=$((MON_H - WIN_H - MARGIN))
          ;;
        br)
          X=$((MON_W - WIN_W - MARGIN))
          Y=$((MON_H - WIN_H - MARGIN))
          ;;
      esac
      
      hyprctl dispatch movewindowpixel exact "$X" "$Y",class:^\(webcam\)$
    '';
  };

  configFile = pkgs.writeText "webcam-menu.yaml" (
    generators.toYAML { } {
      anchor = "center";
      menu = [
        {
          key = "q";
          desc = "Top Left";
          cmd = "${getExe webcam-move} tl";
        }
        {
          key = "w";
          desc = "Top Right";
          cmd = "${getExe webcam-move} tr";
        }
        {
          key = "a";
          desc = "Bottom Left";
          cmd = "${getExe webcam-move} bl";
        }
        {
          key = "s";
          desc = "Bottom Right";
          cmd = "${getExe webcam-move} br";
        }
      ];
    }
  );
in
pkgs.writeShellApplication {
  name = "webcam-menu";
  text = ''
    exec ${getExe pkgs.wlr-which-key} ${configFile}
  '';
}
