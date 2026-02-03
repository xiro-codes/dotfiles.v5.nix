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
      serverAddress = lib.mkOption {
        type = lib.types.str;
        default = "http://${config.osConfig.local.hosts.zimaos or "zimaos.local"}:8080/main";
        example = "http://cache.example.com:8080/nixos";
        description = "Attic binary cache server URL (automatically uses host from local.hosts module)";
      };
      publicKey = lib.mkOption {
        type = lib.types.str;
        default = "main:CqlQUu3twINKw6EvYnbk=";
        example = "cache:AbCdEf1234567890+GhIjKlMnOpQrStUvWxYz==";
        description = "Public key for cache verification";
      };
    };

    # SSH configuration
    ssh = {
      enable = lib.mkEnableOption "configure ssh for user";
      masterKeyPath = lib.mkOption {
        type = lib.types.str;
        default = "~/.ssh/id_ed25519";
        example = "~/.ssh/id_rsa";
        description = "Path to the SSH master private key file";
      };
      hosts = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          Sapphire = config.osConfig.local.hosts.sapphire or "sapphire.local";
          Ruby = config.osConfig.local.hosts.ruby or "ruby.local";
        };
        example = { Sapphire = "sapphire.local"; Ruby = "ruby.local"; };
        description = "Mapping of SSH host aliases to hostnames or IP addresses (automatically uses hosts from local.hosts module)";
      };
    };

    # Secrets configuration
    secrets = {
      enable = lib.mkEnableOption "Use secrets";
      sopsFile = lib.mkOption {
        type = lib.types.path;
        default = ../../../secrets/secrets.yaml;
        example = lib.literalExpression "../secrets/user-secrets.yaml";
        description = "Path to the encrypted yaml file";
      };
      keys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "github/token" "api/openai" "passwords/vpn" ];
        description = "List sops keys to automatically map to $HOME/.secrets/";
      };
    };

    # System variables
    variables = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable system environment variables for common tools and applications";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
        example = "vim";
        description = "Default terminal text editor";
      };
      guiEditor = lib.mkOption {
        type = lib.types.str;
        default = "neovide";
        example = "code";
        description = "Default GUI text editor";
      };
      fileManager = lib.mkOption {
        type = lib.types.str;
        default = "ranger";
        example = "lf";
        description = "Default terminal file manager";
      };
      guiFileManager = lib.mkOption {
        type = lib.types.str;
        default = "pcmanfm";
        example = "nautilus";
        description = "Default GUI file manager";
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "kitty";
        example = "alacritty";
        description = "Default terminal emulator";
      };
      launcher = lib.mkOption {
        type = lib.types.str;
        default = "rofi -show drun";
        example = "wofi --show drun";
        description = "Default application launcher command";
      };
      wallpaper = lib.mkOption {
        type = lib.types.str;
        default = "hyprpaper";
        example = "swaybg";
        description = "Default wallpaper daemon or manager";
      };
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
        example = "chromium";
        description = "Default web browser";
      };
      statusBar = lib.mkOption {
        type = lib.types.str;
        default = "hyprpanel";
        example = "waybar";
        description = "Default status bar or panel application";
      };
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
            hostname = config.osConfig.local.hosts.zimaos or "zimaos.local";
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
