{ config, lib, pkgs, inputs, currentHostUsers, ... }:

let
  cfg = config.local.dotfiles;
  repoPath = "/etc/nixos";
  gitPullSync = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.git-pull-sync;
in
{
  options.local.dotfiles = {
    enable = lib.mkEnableOption "Dotfiles management";
    
    # Git sync options
    sync = {
      enable = lib.mkEnableOption "Automated git sync";
      interval = lib.mkOption {
        type = lib.types.str;
        default = "30m";
        example = "1h";
        description = "How often to pull changes from git (systemd time span format: 30m, 1h, 2h, etc.)";
      };
    };
    
    # Maintenance options
    maintenance = {
      enable = lib.mkEnableOption "System maintenance (GC and optimization)";
      autoUpgrade = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to automatically pull from git and upgrade";
      };
      upgradeFlake = lib.mkOption {
        type = lib.types.str;
        default = "git+http://${config.local.hosts.zimaos}:3002/xiro/dotfiles.nix.git";
        example = "github:user/dotfiles";
        description = "Flake URL for system auto-upgrade";
      };
    };
    
    # Repository permissions options
    repo = {
      enable = lib.mkEnableOption "Manage /etc/nixos permissions and symlinks";
      editorGroup = lib.mkOption {
        type = lib.types.str;
        default = "wheel";
        example = "users";
        description = "Group that has write access to the /etc/nixos repository";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Git sync configuration
    programs.ssh = lib.mkIf cfg.sync.enable {
      extraConfig = ''
        Host github.com
          HostName github.com
          User git
          IdentityFile /root/.ssh/github

        Host gitea
          HostName ${config.local.hosts.zimaos}
          User git
          Port 222
          IdentityFile /root/.ssh/github
      '';
    };
    
    systemd.services.dotfiles-sync = lib.mkIf cfg.sync.enable {
      description = "Auto-pull changes for /etc/nixos dotfiles";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${lib.getExe gitPullSync}";
      };
    };
    
    systemd.timers.dotfiles-sync = lib.mkIf cfg.sync.enable {
      description = "Timer for dotfiles-sync service";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = cfg.sync.interval;
        Unit = "dotfiles-sync.service";
      };
    };
    
    # Maintenance configuration
    nix.settings.auto-optimise-store = lib.mkIf cfg.maintenance.enable true;
    
    nix.gc = lib.mkIf cfg.maintenance.enable {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    
    system.autoUpgrade = lib.mkIf (cfg.maintenance.enable && cfg.maintenance.autoUpgrade) {
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
    
    systemd.services.post-upgrade-notify = lib.mkIf (cfg.maintenance.enable && cfg.maintenance.autoUpgrade) {
      description = "Notify user of system upgrade";
      serviceConfig.Type = "oneshot";
      script = ''
        ${lib.getExe' pkgs.libnotify "notify-send"} "NixOS" "System was successfully upgraded and optimized."
      '';
    };
    
    # Repository permissions configuration
    system.activationScripts.repoPermissions = lib.mkIf cfg.repo.enable {
      text = ''
        chgrp -R ${cfg.repo.editorGroup} /etc/nixos
        chmod -R g+w /etc/nixos
      '';
    };
    
    system.activationScripts.userFileOwnership = lib.mkIf cfg.repo.enable {
      text = lib.concatMapStringsSep "\n"
        (username: ''
          find /etc/nixos/home -name "${username}@*.nix" -exec chown ${username} {} +
          find /etc/nixos/home -name "${username}@*.nix" -exec chmod 644 {} +
        '')
        currentHostUsers;
    };
    
    system.userActivationScripts = lib.mkIf cfg.repo.enable (builtins.listToAttrs (
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
