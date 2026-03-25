{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.local.localization;
in
{
  options.local.localization = {
    enable = mkEnableOption "Localization settings (timezone and locale)";
    
    timeZone = mkOption {
      type = types.str;
      default = "America/Chicago";
      example = "Europe/London";
      description = "System timezone (use `timedatectl list-timezones` to see available options)";
    };
    
    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      example = "en_GB.UTF-8";
      description = "Default system locale for language, formatting, and character encoding";
    };
  };

  config = mkIf cfg.enable {
    time.timeZone = cfg.timeZone;

    i18n.defaultLocale = cfg.locale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.locale;
      LC_IDENTIFICATION = cfg.locale;
      LC_MEASUREMENT = cfg.locale;
      LC_MONETARY = cfg.locale;
      LC_NAME = cfg.locale;
      LC_NUMERIC = cfg.locale;
      LC_PAPER = cfg.locale;
      LC_TELEPHONE = cfg.locale;
      LC_TIME = cfg.locale;
    };
  };
}
