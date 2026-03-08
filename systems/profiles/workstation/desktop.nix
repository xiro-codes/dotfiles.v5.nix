{ inputs, pkgs, ... }:
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
  nixpkgs.overlays = [
    (self: super: {
      libbluray = super.libbluray.override {
        withAACS = true;
        withBDplus = true;
      };
    })
  ];
  environment.systemPackages = with pkgs; [ vlc ];
  programs = {
    firefox.enable = true;
    gpu-screen-recorder.enable = true;
  };
}
