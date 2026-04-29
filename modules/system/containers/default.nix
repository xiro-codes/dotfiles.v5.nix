{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    filterAttrs
    attrNames
    genAttrs
    listToAttrs
    ;
  cfg = config.local.containers;
  # Discover containers in systems/containers/
  containerDir = ../../../systems/containers;
  containerNames =
    if builtins.pathExists containerDir then
      attrNames (filterAttrs (n: v: v == "directory") (builtins.readDir containerDir))
    else
      [ ];
in
{
  options.local.containers = genAttrs containerNames (name: {
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

  config = {
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
  };
}
