{
  config,
  lib,
  pkgs,
  inputs,
  self,
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
    unique
    ;
  cfg = config.local;
  mkStrOpt =
    default:
    mkOption {
      type = types.str;
      inherit default;
    };
  userSops = pkgs.user-sops;
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
          Jade = config.osConfig.local.network-hosts.jade or "jade.local";
          Slate = config.osConfig.local.network-hosts.slate or "slate.local";
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
        default = "${self}/secrets/secrets.yaml";
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
        settings =
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
              hostname = config.osConfig.local.network-hosts.sapphire or "sapphire.local";
              port = 222;
              user = "git";
              identityFile = "~/.ssh/github";
            };
            "*" = {
              user = config.home.username;
              addKeysToAgent = "yes";
              controlMaster = "auto";
              controlPath = "~/.ssh/master-%r@%h:%p";
              setEnv = "TERM=xterm-256color";
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
        secrets = genAttrs (unique cfg.secrets.keys) (name: {
          mode = "0400";
          path = "${config.home.homeDirectory}/.secrets/${name}";
        });
      };
    })
  ];
}
