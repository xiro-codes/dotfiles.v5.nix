{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.local.services.jupyter;
  
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    jupyter
    numpy
    matplotlib
    astroquery
    sympy
  ]);
in
{
  options.local.services.jupyter = {
    enable = mkEnableOption "Jupyter Notebook Server";
    
    port = mkOption {
      type = types.port;
      default = 8888;
      description = "Port to listen on";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.jupyter = {
      description = "Jupyter Notebook Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        User = "tod";
        WorkingDirectory = "/home/tod/Jupyter";
        ExecStart = "${pythonEnv}/bin/jupyter-notebook --no-browser --port=${toString cfg.port} --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password=''";
        Restart = "always";
      };
    };

    systemd.tmpfiles.rules = [
      "d /home/tod/Jupyter 0755 tod users -"
    ];
    
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    local.reverse-proxy.proxies.jupyter = {
      port = cfg.port;
    };
  };
}