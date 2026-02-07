{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.local.flatpak;
in
{
  options.local.flatpak = {
    enable = mkEnableOption "Flatpak support";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    system.fsPackages = [ pkgs.flatpak ];

    # Flathub repository
    services.flatpak.remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];

    # System-wide installation of applications
    environment.flatpak.packages = [
      # A modern software store for GNOME
      "org.bazaar.Bazaar"
    ];
  };
}
