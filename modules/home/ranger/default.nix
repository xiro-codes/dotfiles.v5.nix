{pkgs, lib, config, ...}: let 
  inherit (lib) mkOption mkIf types;
  cfg = config.local.ranger;
in {
  options.local.ranger = {
    enable = lib.mkEnableOption "enable ranger";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ranger p7zip unzip];
    local.variables.fileManager = "ranger";
    xdg.configFile = {
      "ranger/rifle.conf".source = ./rifle.conf;
      "ranger/rc.conf".source = ./rc.conf;
      "ranger/plugins/ranger_devicons".source = ./ranger_devicons;
    };
  };
}
