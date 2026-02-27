{ pkgs, lib, config, ... }:
let
  cfg = config.local.yubikey;
in
{
  options.local.yubikey = {
    enable = lib.mkEnableOption "YubiKey support and GPG/SSH intergration";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yubioath-flutter
      ykman
      yubikey-personalization
      yubico-piv-tool
      yubikey-touch-detector
      yubikey-personalization-gui
    ];
    services.udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];
    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-all;
      settings = { default-cache-ttl = 600; max-cache-ttl = 7200; };
    };
    systemd.user.services.yubikey-touch-detector = {
      description = "Detects when your YubiKey is waiting for a touch";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector";
        Restart = "on-failure";
      };
    };
  };
}
