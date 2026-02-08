{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.local.flatpak;
in
{
  options.local.flatpak = {
    enable = mkEnableOption "Flatpak support";
    extraPackages = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "flatpaks to install";
    };

  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;
    services.flatpak.update.onActivation = true;
    # Flathub repository
    services.flatpak.remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];

    # System-wide installation of applications
    services.flatpak.packages = [ "io.github.kolunmi.Bazaar" ] ++ cfg.extraPackages;
  };
}
