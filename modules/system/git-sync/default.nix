{ config, lib, pkgs, ... }:

let
  cfg = config.local.gitSync;
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
  options.local.gitSync = {
    enable = lib.mkEnableOption "Automated git sync ";
    interval = lib.mkOption {
      type = lib.types.str;
      default = "30m";
      description = "How often to pull changes";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      # We use knownHosts or matchBlocks here to ensure git pull works
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
    systemd.services.dotfiles-sync = {
      description = "Auto-pull changes for /etc/nixos dotfiles";
      serviceConfig = {
        Type = "oneshot";
        User = "root"; # Needs root to write to /etc/nixos
        ExecStart = "${lib.getExe syncScript}";
      };
    };
    systemd.timers.dotfiles-sync = {
      description = "Timer for dotfiles-sync service";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = cfg.interval;
        Unit = "dotfiles-sync.service";
      };
    };
  };
}


