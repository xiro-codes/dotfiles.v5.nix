{
  pkgs,
  cfg,
}:
[
  {
    "layer" = "top";
    "position" = "top";
    "mod" = "dock";
    "exclusive" = true;
    "passtrough" = false;
    "gtk-layer-shell" = true;
    "height" = 40;
    "modules-left" = [
      "clock"
      "network"
      "cpu"
      "memory"
      "hyprland/workspaces"
    ];
    "modules-center" = [ "hyprland/window" ];
    "modules-right" = [
      "tray"

      "wireplumber"
      "mpd"
    ];
    "network" = {
      "format-wifi" = " {ipaddr}";
      "format-ethernet" = "󰈀 {ipaddr}";
      "format-linked" = "{ifname} (No IP) ";
      "format-disconnected" = "⚠  Disconnected";
      "tooltip-format" = "{ifname}: {ipaddr}";
    };
    "hyprland/window" = {
      "format" = "{}";
    };
    "bluetooth" = {
      "format-on" = "";
      "format-off" = "󰂲";
      "format-connected" = "󰂱 {num_connections}";
    };
    "mpd" = {
      "format" = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}: Playing [{title}]";
      "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}🎧 No Song";
      "random-icons" = {
        "on" = " ";
      };
      "repeat-icons" = {
        "on" = " ";
      };
      "single-icons" = {
        "on" = "1";
      };
      "state-icons" = {
        "paused" = "";
        "playing" = "";
      };
    };
    "idle_inhibitor" = {
      "format" = "{icon}";
      "format-icons" = {
        "activated" = "";
        "deactivated" = "";
      };
    };
    "custom/weather" = {
      "format" = "{} °";
      "tooltip" = true;
      "interval" = 3600;
      "exec" = "${pkgs.lib.getExe pkgs.wttrbar} --fahrenheit --main-indicator 'temp_F'";
      "return-type" = "json";
    };
    "hyprland/workspaces" = {
      "disable-scroll" = true;
      "all-outputs" = false;
      "format" = "{icon}";
      "persistent_workspaces" = {
        "1" = [ "HDMI-A-2" ];
        "2" = [ "HDMI-A-2" ];
        "3" = [ "HDMI-A-2" ];
      };
      "format-icons" = {
        "1" = "一";
        "2" = "二";
        "3" = "三";
      };
    };
    "cpu" = {
      "interval" = 10;
      "format" = " {}%";
      "max-length" = 10;
    };
    "memory" = {
      "interval" = 30;
      "format" = " {}%";
      "format-alt" = " {used:0.1f}G";
      "max-length" = 10;
    };
    "tray" = {
      "icon-size" = 13;
      "tooltip" = false;
      "spacing" = 10;
    };
    "clock" = {
      "interval" = 15;
      "format" = "{:%R %m/%d/%y}";
      "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    };
    "wireplumber" = {
      "format" = "{icon} {volume}%";
      "tooltip" = false;
      "format-muted" = " Muted";
      "format-icons" = {
        "headphone" = "";
        "hands-free" = "";
        "headset" = "";
        "phone" = "";
        "portable" = "";
        "car" = "";
        "default" = [
          ""
          ""
          ""
        ];
      };
    };
  }
]
