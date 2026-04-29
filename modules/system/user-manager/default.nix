{ config, lib, pkgs, currentHostUsers, ... }:
let
  inherit (lib) any genAttrs mkEnableOption mkIf mkOption types;

  cfg = config.local.userManager;
in
{
  options.local.userManager = {
    enable = mkEnableOption "Automatic user group management";
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ "wheel" "networkmanager" "input" "docker" "cdrom" "incus-admin" ];
      example = [ "wheel" "networkmanager" "input" "video" "audio" "docker" ];
      description = "Groups to assign to all auto-discovered users on this host";
    };
    defaultGroups = mkOption {
      readOnly = true;
      default = [ "wheel" "networkmanager" "input" "video" "audio" ];
    };
  };
  config = {
    security.sudo.wheelNeedsPassword = false;

    users.users = genAttrs currentHostUsers (name: {
      isNormalUser = true;
      extraGroups = cfg.extraGroups ++ cfg.defaultGroups;
    });

    programs.fish.enable = true;
  };
}
