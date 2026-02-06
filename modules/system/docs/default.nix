{ config, lib, pkgs, inputs, ... }:

{
  options.local.docs = {
    enable = lib.mkEnableOption "Enable the dotfiles documentation service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3088;
      description = "Port to serve the documentation on.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.self.packages.x86_64-linux.docs;
      description = "The documentation package to serve.";
    };
  };

  config = lib.mkIf config.local.docs.enable {
    systemd.services.docs = {
      description = "Dotfiles Documentation";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.caddy}/bin/caddy file-server --listen "0.0.0.0:${toString config.local.docs.port}" --root "${config.local.docs.package}"
        '';
        Restart = "always";
        User = "nobody";
        Group = "nogroup";
      };
    };
  };
}
