# Workstation profile - For desktop/laptop systems
{ ... }:
{
  local = {
    audio.enable = true;
    bluetooth.enable = true;
    gaming.enable = true;
    desktops = {
      enable = true;
      enableEnv = true;
      hyprland = true;
    };
  };
}
