{ config, lib, pkgs, inputs, currentHostUsers, ... }:

let
  inherit (lib) concatMapStringsSep getExe getExe' mkEnableOption mkIf mkOption types;

  cfg = config.local.dotfiles-sync;
  repoPath = "/etc/nixos";
  gitPullSync = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.git-pull-sync;
in
{
  options.local.dotfiles-sync = {
    enable = mkEnableOption "Dotfiles management";

    # Git sync options
    sync = {
      enable = mkEnableOption "Automated git sync";
      interval = mkOption {
        type = types.str;
        default = "30m";
        example = "1h";
        description = "How often to pull changes from git (systemd time span format: 30m, 1h, 2h, etc.)";
      };
    };

    # Maintenance options
    maintenance = {
      enable = mkEnableOption "System maintenance (GC and optimization)";
      autoUpgrade = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to automatically pull from git and upgrade";
      };
      upgradeFlake = mkOption {
        type = types.str;
        default = "git+http://${config.local.network-hosts.onix}:3002/xiro/dotfiles.nix.git";
        example = "github:user/dotfiles";
        description = "Flake URL for system auto-upgrade";
      };
    };

    # Repository permissions options
    repo = {
      enable = mkEnableOption "Manage /etc/nixos permissions and symlinks";
      editorGroup = mkOption {
        type = types.str;
        default = "wheel";
        example = "users";
        description = "Group that has write access to the /etc/nixos repository";
      };
    };
  };

  config = mkIf cfg.enable {
    # Git sync configuration
    programs.ssh = mkIf cfg.sync.enable {
      extraConfig = ''
        Host github.com
          HostName github.com
          User git
          IdentityFile /root/.ssh/github

        Host gitea
          HostName ${config.local.network-hosts.onix}
          User git
          Port 2222
          IdentityFile /root/.ssh/github
      '';
    };

    systemd.services.dotfiles-sync = mkIf cfg.sync.enable {
      description = "Auto-pull changes for /etc/nixos dotfiles";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${getExe gitPullSync}";
      };
    };

    systemd.timers.dotfiles-sync = mkIf cfg.sync.enable {
      description = "Timer for dotfiles-sync service";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = cfg.sync.interval;
        Unit = "dotfiles-sync.service";
      };
    };

    # Maintenance configuration
    nix.settings.auto-optimise-store = mkIf cfg.maintenance.enable true;

    nix.gc = mkIf cfg.maintenance.enable {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    system.autoUpgrade = mkIf (cfg.maintenance.enable && cfg.maintenance.autoUpgrade) {
      enable = true;
      flake = cfg.maintenance.upgradeFlake;
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
      ];
      dates = "06:00";
      allowReboot = false;
    };

    systemd.services.post-upgrade-notify = mkIf (cfg.maintenance.enable && cfg.maintenance.autoUpgrade) {
      description = "Notify user of system upgrade";
      serviceConfig.Type = "oneshot";
      script = ''
        ${getExe' pkgs.libnotify "notify-send"} "NixOS" "System was successfully upgraded and optimized."
      '';
    };

    # Repository permissions configuration
    system.activationScripts.repoPermissions = mkIf cfg.repo.enable {
      text = ''
        chgrp -R ${cfg.repo.editorGroup} /etc/nixos
        chmod -R g+w /etc/nixos
      '';
    };

    system.activationScripts.userFileOwnership = mkIf cfg.repo.enable {
      text = concatMapStringsSep "\n"
        (username: ''
          find /etc/nixos/home -name "${username}@*.nix" -exec chown ${username} {} +
          find /etc/nixos/home -name "${username}@*.nix" -exec chmod 644 {} +
        '')
        currentHostUsers;
    };

    system.userActivationScripts = mkIf cfg.repo.enable (builtins.listToAttrs (
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
    ));
  };
}
