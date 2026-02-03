# Desktop home profile - GUI applications and desktop environment
{ pkgs, lib, inputs, ... }:
{
  local = {
    hyprland.enable = true;
    kitty.enable = true;
    nixvim.enable = true;
    stylix.enable = true;
    ranger.enable = true;
    fonts.enable = true;
    mpd.enable = true;
    caelestia.enable = true;
  };

  gtk = {
    enable = lib.mkForce true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.packages = with pkgs; [
    caligula
    grim
    slurp
    firefox
    discord
    warp-terminal
  ] ++ (with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
    ai-commit
  ]);
}
