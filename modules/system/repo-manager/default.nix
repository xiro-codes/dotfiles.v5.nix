{ config
, lib
, currentHostUsers
, ...
}:
let
  cfg = config.local.repoManager;
in
{
  options.local.repoManager = {
    enable = lib.mkEnableOption "Manage /etc/nixos";
    editorGroup = lib.mkOption {
      type = lib.types.str;
      default = "wheel";
      description = "Group that has write access to the /etc/nixos repo";
    };
  };
  config = lib.mkIf cfg.enable {
    system.activationScripts.repoPermissions = {
      text = ''
        				chgrp -R ${cfg.editorGroup} /etc/nixos
        				chmod -R g+w /etc/nixos
        			'';
    };
    system.activationScripts.userFileOwnership = {
      text = lib.concatMapStringsSep "\n"
        (username: ''
          				find /etc/nixos/home -name "${username}@*.nix" -exec chown ${username} {} +
          				find /etc/nixos/home -name "${username}@*.nix" -exec chmod 644 {} +
          			'')
        currentHostUsers;
    };
    system.userActivationScripts = builtins.listToAttrs (
      map
        (username: {
          name = "link-repo-${username}";
          value = {
            text = ''
              					ln -sfn /etc/nixos /home/${username}/.dotfiles.nix
              				'';
          };
        })
        currentHostUsers
    );
  };
}
