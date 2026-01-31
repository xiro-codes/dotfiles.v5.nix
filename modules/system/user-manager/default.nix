{ config, lib, pkgs, currentHostUsers, ... }:
let
  cfg = config.local.userManager;
  anyUserUsesFish = lib.any (u: config.users.users.${u}.shell == pkgs.fish)
    currentHostUsers;
in
{
  options.local.userManager = {
    enable = lib.mkEnableOption "Automatic user group management";
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wheel" "networkmanager" "input" ];
      description = "Groups to assign to all auto-discovered users on this host.";
    };
  };
  config = {
    security.sudo.wheelNeedsPassword = false;

    users.users = lib.genAttrs currentHostUsers (name: {
      isNormalUser = true;
      extraGroups = cfg.extraGroups;
    });
    programs.fish.enable = lib.mkIf anyUserUsesFish true;
  };
}
