{ config, lib, inputs, ... }:
let
  cfg = config.local.containers;
  # Discover containers in systems/containers/
  containerDir = ../../../systems/containers;
  containerNames = if builtins.pathExists containerDir 
                   then lib.attrNames (lib.filterAttrs (n: v: v == "directory") (builtins.readDir containerDir))
                   else [];
in
{
  options.local.containers = lib.genAttrs containerNames (name: {
    enable = lib.mkEnableOption "Enable ${name} container";
    autoStart = lib.mkOption { type = lib.types.bool; default = true; description = "Whether to auto-start the container"; };
    privateNetwork = lib.mkOption { type = lib.types.bool; default = true; description = "Whether the container should have a private network stack"; };
    macvlans = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "enp6s0" ]; description = "List of macvlans to assign to the container"; };
  });

  config = {
    containers = lib.listToAttrs (map (name: {
      name = name;
      value = lib.mkIf (cfg.${name}.enable or false) {
        autoStart = cfg.${name}.autoStart;
        privateNetwork = cfg.${name}.privateNetwork;
        macvlans = cfg.${name}.macvlans;
        path = inputs.self.nixosContainers.${name}.config.system.build.toplevel;
      };
    }) containerNames);
  };
}
