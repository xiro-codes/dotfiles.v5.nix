{ config, lib, pkgs, ... }:

let
  cfg = config.local;
  mkStrOpt = default: lib.mkOption { type = lib.types.str; inherit default; };
in
{
  options.local = {
    # Cache configuration
    cache = {
      enable = lib.mkEnableOption "cache module";
      watch = lib.mkEnableOption "enable systemd service to watch cache";
      serverAddress = mkStrOpt "http://10.0.0.65:8080/main";
      publicKey = mkStrOpt "main:CqlQUu3twINKw6EvYnbk=";
    };

    # SSH configuration
    ssh = {
      enable = lib.mkEnableOption "configure ssh for user";
      masterKeyPath = mkStrOpt "~/.ssh/id_ed25519";
      hosts = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = { Sapphire = "10.0.0.67"; Ruby = "10.0.0.66"; };
        description = "Mapping of aliases to hostnames/IPs.";
      };
    };

    # Secrets configuration
    secrets = {
      enable = lib.mkEnableOption "Use secrets";
      sopsFile = lib.mkOption {
        type = lib.types.path;
        default = ../../secrets/secrets.yaml;
        description = "Path to the encrypted yaml file";
      };
      keys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List sops keys to automatically map to $HOME/.secrets/";
      };
    };

    # System variables
    variables = {
      enable = lib.mkEnableOption "System variables";
      editor = mkStrOpt "nvim";
      guiEditor = mkStrOpt "neovide";
      fileManager = mkStrOpt "ranger";
      guiFileManager = mkStrOpt "pcmanfm";
      terminal = mkStrOpt "kitty";
      launcher = mkStrOpt "rofi -show drun";
      wallpaper = mkStrOpt "hyprpaper";
      browser = mkStrOpt "firefox";
      statusBar = mkStrOpt "hyprpanel";
    };
  };

  config = lib.mkMerge [
    # Cache
    (lib.mkIf cfg.cache.enable {
      home.packages = with pkgs; [ attic-client ];
      systemd.user.services.attic-watch = lib.mkIf cfg.cache.watch {
        Unit = {
          Description = "Watch Nix store and push to Attic cache";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.attic-client}/bin/attic watch-store main";
          Restart = "always";
          RestartSec = 5;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    })

    # SSH
    (lib.mkIf cfg.ssh.enable {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = (lib.mapAttrs
          (alias: host: {
            hostname = host;
            user = config.home.username;
            identityFile = cfg.ssh.masterKeyPath;
            forwardAgent = true;
          })
          cfg.ssh.hosts) // {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = "~/.ssh/github";
          };
          "gitea" = {
            hostname = "10.0.0.65";
            port = 222;
            user = "git";
            identityFile = "~/.ssh/github";
          };
          "*" = {
            user = config.home.username;
            addKeysToAgent = "yes";
            controlMaster = "auto";
            controlPath = "~/.ssh/master-%r@%h:%p";
            setEnv = { TERM = "xterm-256color"; };
          };
        };
      };
    })

    # Secrets
    (lib.mkIf cfg.secrets.enable {
      home.packages = with pkgs; [
        (writeShellScriptBin "user-sops" ''
          export SOPS_AGE_KEY=$(${lib.getExe ssh-to-age} -private-key -i $HOME/.ssh/id_sops)
          if [ -z "$SOPS_AGE_KEY" ]; then
            echo "Error: Could not derive Age key from $HOME/.ssh/id_sops"
            exit 1
          fi
          exec ${lib.getExe sops} "$@"
        '')
      ];
      sops = {
        age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_sops" ];
        defaultSopsFile = cfg.secrets.sopsFile;
        secrets = lib.genAttrs cfg.secrets.keys
          (name: {
            mode = "0400";
            path = "${config.home.homeDirectory}/.secrets/${name}";
          });
      };
    })

    # Variables
    (lib.mkIf cfg.variables.enable {
      home.sessionVariables = {
        EDITOR = cfg.variables.editor;
        VISUAL = cfg.variables.editor;
        GUI_EDITOR = cfg.variables.guiEditor;
        FILEMANAGER = cfg.variables.fileManager;
        GUI_FILEMANAGER = cfg.variables.guiFileManager;
        TERMINAL = cfg.variables.terminal;
        GUI_TERMINAL = cfg.variables.terminal;
        LAUNCHER = cfg.variables.launcher;
        BROWSER = cfg.variables.browser;
        WALLPAPER = cfg.variables.wallpaper;
        STATUS_BAR = cfg.variables.statusBar;
      };
    })
  ];
}
