{ pkgs, ... }:
{
  local = {
    hyprland.enable = true;
    hyprland.layout = "scrolling";
  };

  home.packages = with pkgs; [
    # Screenshot tools
    caligula
    grim
    slurp

    # Notifications
    libnotify
  ];
}
