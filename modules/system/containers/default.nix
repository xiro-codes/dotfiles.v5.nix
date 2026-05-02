{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkMerge
    mkEnableOption
    mkOption
    mkIf
    types
    filterAttrs
    attrNames
    genAttrs
    listToAttrs
    last
    strings
    range
    fixedPoints
    splitString
    ;
  cfg = config.local.containers;
  clusterCfg = config.local.cluster;
  # Discover containers in systems/containers/
  containerDir = ../../../systems/containers;
  containerNames =
    if builtins.pathExists containerDir then
      attrNames (filterAttrs (n: v: v == "directory") (builtins.readDir containerDir))
    else
      [ ];
in
{
  options.local = {
    containers = genAttrs containerNames (name: {
      enable = mkEnableOption "Enable ${name} container";
      autoStart = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to auto-start the container";
      };
      privateNetwork = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the container should have a private network stack";
      };
      macvlans = mkOption {
        type = types.listOf types.str;
        default = [ "enp6s0" ];
        description = "List of macvlans to assign to the container";
      };
    });
    cluster = {
      enable = mkEnableOption "Spinup a cluster of containers";
      nameSpace = mkOption {
        type = types.str;
        default = "node";
        description = "Base name for the constiners in custer";
      };
      size = mkOption {
        type = types.number;
        default = 5;
        description = "Number of containers in custer";
      };
      template = mkOption {
        type = types.path;
        default = "";
        description = "The container to replacte over the custer";
      };
    };
  };
  config = mkMerge [
    {
      containers =
        let
          containerIndices = range 1 clusterCfg.size;
        in
        genAttrs (map (i: "${clusterCfg.nameSpace}-${toString i}") containerIndices) (name: {
          autoStart = true;
          privateNetwork = true;
          hostAddress = "10.233.0.1";
          localAddress = "10.233.0.${toString ((strings.toInt (last (splitString "-" name))) + 1)}";
          config =
            { pkgs, ... }:
            {
              imports = [
                inputs.inputs-nix.nixosModules.default
              ];
              system.stateVersion = "26.05";
              networking.firewall.enable = false;
              services.nginx = {
                enable = true;
                virtualHosts.localhost.locations."/".extraConfig = ''
                  add_header Content-Type text/plain;
                  return 200 "Container: ${name}\n";
                '';
              };
            };
        });
    }
    {
      containers = listToAttrs (
        map (name: {
          name = name;
          value = mkIf (cfg.${name}.enable or false) {
            autoStart = cfg.${name}.autoStart;
            privateNetwork = cfg.${name}.privateNetwork;
            macvlans = cfg.${name}.macvlans;
            path = inputs.self.nixosContainers.${name}.config.system.build.toplevel;
          };
        }) containerNames
      );
    }
  ];
}
