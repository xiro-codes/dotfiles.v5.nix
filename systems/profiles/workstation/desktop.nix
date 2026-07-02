{
  inputs,
  pkgs,
  ...
}:
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

  # virtualisation.waydroid.enable = true;

  programs = {
    gpu-screen-recorder.enable = true;
  };
}
