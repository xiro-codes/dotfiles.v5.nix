{ config, lib, pkgs, ... }:

{
  options.services.docs = {
    enable = lib.mkEnableOption "Enable the dotfiles documentation service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "Port to serve the documentation on.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.docs-site;
      description = "The documentation package to serve.";
    };
  };

  config = lib.mkIf config.services.docs.enable {
    systemd.services.docs = {
      description = "Dotfiles Documentation";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.caddy}/bin/caddy file-server --listen ":${toString config.services.docs.port}" --root "${config.services.docs.package}"
        '';
        Restart = "always";
        User = "nobody";
        Group = "nogroup";
      };
    };
  };
}
