{
  config,
  lib,
  pkgs,
  currentHostUsers,
  ...
}:
let
  inherit (lib)
    any
    genAttrs
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.userManager;
in
{
  options.local.userManager = {
    enable = mkEnableOption "Automatic user group management";
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [
        "wheel"
        "networkmanager"
        "input"
        "docker"
        "cdrom"
        "incus-admin"
      ];
      example = [
        "wheel"
        "networkmanager"
        "input"
        "video"
        "audio"
        "docker"
      ];
      description = "Groups to assign to all auto-discovered users on this host";
    };
    defaultGroups = mkOption {
      readOnly = true;
      description = "Default groups to assign to all auto-discovered users on this host";
      default = [
        "wheel"
        "networkmanager"
        "input"
        "video"
        "audio"
      ];
    };
  };
  config = {
    security.sudo.wheelNeedsPassword = false;

    users.users = genAttrs currentHostUsers (name: {
      isNormalUser = true;
      extraGroups = cfg.extraGroups ++ cfg.defaultGroups;
    });

    system.userActivationScripts = builtins.listToAttrs (
      map (username: {
        name = "link-user-folders-${username}";
        value = {
          text = ''
            if [ -d "/media/Scratch" ]; then
              mkdir -p /media/Scratch/${username}/{Projects,Downloads,Documents,Pictures,Videos,Music}
              ln -sfn /media/Scratch/${username}/Projects /home/${username}/Projects
              ln -sfn /media/Scratch/${username}/Downloads /home/${username}/Downloads
              ln -sfn /media/Scratch/${username}/Documents /home/${username}/Documents
              ln -sfn /media/Scratch/${username}/Pictures /home/${username}/Pictures
              ln -sfn /media/Scratch/${username}/Videos /home/${username}/Videos
              ln -sfn /media/Scratch/${username}/Music /home/${username}/Music
            else
              echo "Scratch directory not found. Skipping media folder links."
            fi

            if [ -d "/media/Backups" ]; then
              mkdir -p /media/Backups/${username}
              ln -sfn /media/Backups/${username} /home/${username}/.backups
            else
              echo "Backups directory not found. Skipping backups link."
            fi
          '';
        };
      }) currentHostUsers
    );

    programs.fish.enable = true;
  };
}
