# Desktop home profile - GUI applications and desktop environment
{ pkgs, lib, inputs, ... }:
{
  local = {
    # Desktop environment
    hyprland.enable = true;
    kitty.enable = true;
    stylix.enable = true;
    fonts.enable = true;
    
    # Desktop applications
    nixvim.enable = true;
    ranger.enable = true;
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
    # Desktop applications
    firefox
    discord
    warp-terminal
    
    # Screenshot tools
    caligula
    grim
    slurp
    
    # Fonts (for GUI)
    cascadia-code
    
    # Notifications
    libnotify
  ] ++ (with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
    ai-commit
  ]);
}
