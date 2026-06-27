{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.local.security;
in
{
  options.local.security = {
    enable = mkEnableOption "Centralized security settings";
    adminUser = mkOption {
      type = types.str;
      default = "tod";
      example = "admin";
      description = "The main admin user to grant passwordless sudo/doas access and SSH key authorization";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.local.secrets.enable;
        message = "security requires local.secrets to be enabled";
      }
    ];

    # doas setup (Modern, lightweight alternative to sudo)
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ cfg.adminUser ];
          keepEnv = true;
          noPass = true;
        }
      ];
    };

    # sudo setup (For backward compatibility and deploy-rs)
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    # SSH Service Hardening
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    # Apply keys to root and the admin user
    users.users = {
      root.openssh.authorizedKeys.keyFiles = [
        config.sops.secrets."ssh_pub_ruby/master".path
        config.sops.secrets."ssh_pub_sapphire/master".path
        config.sops.secrets."ssh_pub_slate/master".path
      ];
    } // lib.optionalAttrs (cfg.adminUser != "root") {
      ${cfg.adminUser}.openssh.authorizedKeys.keyFiles = [
        config.sops.secrets."ssh_pub_ruby/master".path
        config.sops.secrets."ssh_pub_sapphire/master".path
        config.sops.secrets."ssh_pub_slate/master".path
      ];
    };

    # Nix Daemon trust (Crucial for remote deployments)
    nix.settings.trusted-users = [
      "root"
      cfg.adminUser
    ];

    local.secrets.keys = [
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_slate/master"
    ];
  };
}
