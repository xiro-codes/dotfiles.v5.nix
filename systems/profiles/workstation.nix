# Workstation profile - For desktop/laptop systems
{ inputs, ... }:
{
  environment.systemPackages = [
    inputs.zen-browser.packages.x86_64-linux.default
  ];
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
