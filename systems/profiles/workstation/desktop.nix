{ ... }:
{
  local = {
    gaming.enable = true;
    flatpak.enable = true;
    desktops = {
      enable = true;
      enableEnv = true;
      hyprland = true;
    };
  };
  programs = {
    firefox.enable = true;
    gpu-screen-recorder.enable = true;
  };
}
