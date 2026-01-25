{ config, lib, pkgs, ... }:

let
  cfg = config.local.maintenance;
in
{
  options.local.maintenance = {
    enable = lib.mkEnableOption "maintenance module";
    autoUpgrade = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to automatically pull from git and upgrade.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings.auto-optimise-store = true;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    system.autoUpgrade = lib.mkIf cfg.autoUpgrade {
      enable = true;
      flake = "git+http://10.0.0.65:3002/xiro/dotfiles.nix.git";
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
      ];
      dates = "06:00";
      allowReboot = false;
    };
    systemd.services.post-upgrade-notify = lib.mkIf cfg.autoUpgrade {
      description = "Notify user of system upgrade";
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.libnotify}/bin/notify-send "NixOS" "System was successfully upgraded and optimized."
      '';
    };
  };
}
