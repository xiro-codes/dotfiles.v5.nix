{ pkgs, ... }:
{
  local = {
    hyprland.enable = true;
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
