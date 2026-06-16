{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types mkIf mkForce;
  cfg = config.local.onboarding;
in
{
  options.local.onboarding = {
    enable = mkOption {
      type = types.bool;
      default = builtins.getEnv "NIXOS_ONBOARDING" == "1";
      description = "onboarding mode for new/existing hosts (disables secrets, security, and nix-cache, enables open SSH)";
    };
  };

  config = mkIf cfg.enable {
    local.secrets.enable = mkForce false;
    local.security.enable = mkForce false;
    local.harmonia-client.enable = mkForce false;
    local.zerotier.enable = mkForce false;

    services.openssh = {
      enable = mkForce true;
      settings = {
        PasswordAuthentication = mkForce true;
        PermitRootLogin = mkForce "yes";
      };
    };
  };
}
