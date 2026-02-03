{ config, lib, pkgs, currentHostUsers, ... }:

let
  cfg = config.local.dotfiles;
  repoPath = "/etc/nixos";
  
  syncScript = pkgs.writeShellScriptBin "git-pull-sync" ''
    cd ${repoPath}
    
    # Check if the directory is a git repo
    if [ ! -d .git ]; then
      echo "Not a git repository: ${repoPath}"
      exit 0
    fi

    # Check for uncommitted changes
    if ! ${pkgs.git}/bin/git diff-index --quiet HEAD --; then
      echo "Local changes detected in ${repoPath}. Skipping auto-pull to avoid conflicts."
      exit 0
    fi

    echo "No local changes. Attempting to pull from remote origin..."
    ${pkgs.git}/bin/git pull origin main || ${pkgs.git}/bin/git pull origin master
  '';
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
        description = "How often to pull changes from git";
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
        default = "git+http://10.0.0.65:3002/xiro/dotfiles.nix.git";
        description = "Flake URL for auto-upgrade";
      };
    };
    
    # Repository permissions options
    repo = {
      enable = lib.mkEnableOption "Manage /etc/nixos permissions and symlinks";
      editorGroup = lib.mkOption {
        type = lib.types.str;
        default = "wheel";
        description = "Group that has write access to the /etc/nixos repo";
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
          HostName 10.0.0.65
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
        ExecStart = "${lib.getExe syncScript}";
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
        ${pkgs.libnotify}/bin/notify-send "NixOS" "System was successfully upgraded and optimized."
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
