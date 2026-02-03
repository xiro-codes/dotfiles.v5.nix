{ pkgs, lib, config, ... }:

let
  cfg = config.local.security;
in
{
  options.local.security = {
    enable = lib.mkEnableOption "Centralized security settings";
    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "tod";
      example = "admin";
      description = "The main admin user to grant passwordless sudo/doas access and SSH key authorization";
    };
  };

  config = lib.mkIf cfg.enable {

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
    users.users.root.openssh.authorizedKeys.keyFiles = [
      config.sops.secrets."ssh_pub_ruby/master".path
      config.sops.secrets."ssh_pub_sapphire/master".path
    ];

    users.users.${cfg.adminUser}.openssh.authorizedKeys.keyFiles = [
      config.sops.secrets."ssh_pub_ruby/master".path
      config.sops.secrets."ssh_pub_sapphire/master".path
    ];

    # Nix Daemon trust (Crucial for remote deployments)
    nix.settings.trusted-users = [ "root" cfg.adminUser ];
  };
}
