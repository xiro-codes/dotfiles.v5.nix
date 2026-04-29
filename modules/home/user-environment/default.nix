{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    genAttrs
    getExe
    literalExpression
    mapAttrs
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.local;
  mkStrOpt =
    default:
    mkOption {
      type = types.str;
      inherit default;
    };
  userSops = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.user-sops;
  geminiKeyPath = "$HOME/.secrets/gemini/crush_agent_key";
in
{
  options.local = {
    # SSH configuration
    ssh = {
      enable = mkEnableOption "configure ssh for user";
      masterKeyPath = mkOption {
        type = types.str;
        default = "~/.ssh/id_ed25519";
        example = "~/.ssh/id_rsa";
        description = "Path to the SSH master private key file";
      };
      hosts = mkOption {
        type = types.attrsOf types.str;
        default = {
          Sapphire = config.osConfig.local.network-hosts.sapphire or "sapphire.local";
          Ruby = config.osConfig.local.network-hosts.ruby or "ruby.local";
          Onix = config.osConfig.local.network-hosts.onix or "onix.local";
          Jade = config.osConfig.local.network-hosts.jade or "jade.local";
        };
        example = {
          Sapphire = "sapphire.local";
          Ruby = "ruby.local";
        };
        description = "Mapping of SSH host aliases to hostnames or IP addresses (automatically uses hosts from local.network-hosts module)";
      };
    };

    # Secrets configuration
    secrets = {
      enable = mkEnableOption "Use secrets";
      sopsFile = mkOption {
        type = types.path;
        default = ../../../secrets/secrets.yaml;
        example = literalExpression "../secrets/user-secrets.yaml";
        description = "Path to the encrypted yaml file";
      };
      keys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "github/token"
          "api/openai"
          "passwords/vpn"
        ];
        description = "List sops keys to automatically map to $HOME/.secrets/";
      };
    };

    # System variables
    variables = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable system environment variables for common tools and applications";
      };
      editor = mkOption {
        type = types.str;
        default = "nvim";
        example = "vim";
        description = "Default terminal text editor";
      };
      guiEditor = mkOption {
        type = types.str;
        default = "neovide";
        example = "code";
        description = "Default GUI text editor";
      };
      fileManager = mkOption {
        type = types.str;
        default = "yazi";
        example = "lf";
        description = "Default terminal file manager";
      };
      guiFileManager = mkOption {
        type = types.str;
        default = "nautilus";
        example = "nautilus";
        description = "Default GUI file manager";
      };
      terminal = mkOption {
        type = types.str;
        default = "kitty";
        example = "alacritty";
        description = "Default terminal emulator";
      };
      launcher = mkOption {
        type = types.str;
        default = "rofi -show drun";
        example = "wofi --show drun";
        description = "Default application launcher command";
      };
      wallpaper = mkOption {
        type = types.str;
        default = "hyprpaper";
        example = "swaybg";
        description = "Default wallpaper daemon or manager";
      };
      browser = mkOption {
        type = types.str;
        default = "firefox";
        example = "chromium";
        description = "Default web browser";
      };
      statusBar = mkOption {
        type = types.str;
        default = "hyprpanel";
        example = "waybar";
        description = "Default status bar or panel application";
      };
    };

    # Caelestia configuration
    caelestia = {
      colorScheme = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "gruvbox";
        description = "Color scheme name for Caelestia (e.g., 'gruvbox', 'catppuccin'). If null, uses dynamic wallpaper colors.";
      };
    };
  };

  config = mkMerge [
    # SSH
    (mkIf cfg.ssh.enable {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks =
          (mapAttrs (alias: host: {
            hostname = host;
            user = config.home.username;
            identityFile = cfg.ssh.masterKeyPath;
            forwardAgent = true;
          }) cfg.ssh.hosts)
          // {
            "github.com" = {
              hostname = "github.com";
              user = "git";
              identityFile = "~/.ssh/github";
            };
            "gitea" = {
              hostname = config.osConfig.local.network-hosts.onix or "onix.local";
              port = 222;
              user = "git";
              identityFile = "~/.ssh/github";
            };
            "*" = {
              user = config.home.username;
              addKeysToAgent = "yes";
              controlMaster = "auto";
              controlPath = "~/.ssh/master-%r@%h:%p";
              setEnv = {
                TERM = "xterm-256color";
              };
            };
          };
      };
    })

    # Secrets
    (mkIf cfg.secrets.enable {
      home.packages = [
        userSops
      ];
      sops = {
        age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_sops" ];
        defaultSopsFile = cfg.secrets.sopsFile;
        secrets = genAttrs cfg.secrets.keys (name: {
          mode = "0400";
          path = "${config.home.homeDirectory}/.secrets/${name}";
        });
      };
    })

    # Variables
    (mkIf cfg.variables.enable {
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
        GEMINI_API_KEY = "$(cat ${geminiKeyPath})";
      };
    })
  ];
}
