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
      # TODO: SECURITY SMELL: Unconditional assignment of 'wheel', 'docker', etc., to all users.
      # This defeats multi-user isolation by granting root-equivalent access to everyone.
      # Consider pulling a `local.isAdmin` boolean from the user's Home Manager config instead.
      extraGroups = cfg.extraGroups ++ cfg.defaultGroups;
    });

    # TODO: ARCHITECTURE SMELL: Imperative bash script running as root.
    # This script bypasses declarative paradigms, running on every boot to blindly create symlinks.
    # Consider replacing with declarative `systemd.tmpfiles.rules` or Home Manager `home.file."Projects".source`.
    system.userActivationScripts = builtins.listToAttrs (
      map (username: {
        name = "link-user-folders-${username}";
        value = {
          text = ''
            if [ -d "/media/Scratch" ]; then
              mkdir -p /media/Scratch/${username}/{Downloads,Documents,Pictures,Videos,Music,Templates}
              ln -sfn /media/Scratch/${username}/Downloads /home/${username}/Downloads
              ln -sfn /media/Scratch/${username}/Documents /home/${username}/Documents
              ln -sfn /media/Scratch/${username}/Pictures /home/${username}/Pictures
              ln -sfn /media/Scratch/${username}/Videos /home/${username}/Videos
              ln -sfn /media/Scratch/${username}/Music /home/${username}/Music
              ln -sfn /media/Scratch/${username}/Templates /home/${username}/Templates
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
