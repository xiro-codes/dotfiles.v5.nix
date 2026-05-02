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
    range
    attrValues
    listToAttrs
    map
    ;

  cfg = config.local.cluster;

  # Re-use the discovery utilities rather than duplicating them.
  paths = import ../../../parts/discovery/paths.nix;
  usersLib = import ../../../parts/discovery/users.nix { inherit lib; };
  hostToUsersMap = usersLib.getUserHostMap paths.home;

  # Mirrors flake.nix globals.
  globalNixosModules = [
    inputs.inputs-nix.nixosModules.default
    inputs.nix-topology.nixosModules.default
  ];
  globalHomeModules = [ inputs.inputs-nix.homeModules.default ];

  # Builds a fully-featured container config for a named template, identical to
  # what genConfigs in parts/discovery/nixos.nix produces for a regular system.
  mkContainerSystem =
    { name, idx, templateName }:
    let
      templateUsers = hostToUsersMap.${templateName} or [ ];
    in
    { ... }: {
      imports =
        globalNixosModules
        ++ [
          (paths.systems + "/containers/${templateName}/configuration.nix")
          {
            networking.hostName = name;
            local.secrets.enable = true;
            home-manager = {
              backupFileExtension = "backup";
              backupCommand = "${inputs.nixpkgs.legacyPackages.x86_64-linux.trash-cli}/bin/trash";
              extraSpecialArgs = { inherit inputs; };
              sharedModules = (attrValues inputs.self.homeModules) ++ globalHomeModules;
              users = listToAttrs (
                map (u: {
                  name = u.user;
                  value = import (paths.home + "/${u.filename}");
                }) templateUsers
              );
            };
          }
        ]
        ++ (attrValues inputs.self.nixosModules);
      _module.args = {
        inherit inputs;
        currentHostName = name;
        currentHostUsers = map (u: u.user) templateUsers;
        nodeId = idx;
      };
    };
in
{
  options.local.cluster = {
    enable = mkEnableOption "Spin up a cluster of containers";
    nameSpace = mkOption {
      type = types.str;
      default = "node";
      description = "Base name prefix for containers (e.g. \"node\" → node-1, node-2, …)";
    };
    size = mkOption {
      type = types.number;
      default = 5;
      description = "Number of containers in the cluster";
    };
    template = mkOption {
      type = types.either types.str types.anything;
      description = ''
        The container definition to replicate. One of:
          - string  — name of a container in systems/containers/<name>; receives nodeId
                      via module args and gets full system setup (modules, home-manager, etc.)
          - function — (idx: NixOS module); called with the node index for full control.
      '';
    };
    hostAddress = mkOption {
      type = types.str;
      default = "10.233.0.1";
      description = "Host-side veth IP, shared across all containers";
    };
    subnet = mkOption {
      type = types.str;
      default = "10.233.0";
      description = "The /24 subnet prefix; containers are assigned .2, .3, .4, …";
    };
  };

  config = mkIf cfg.enable {
    containers =
      let
        templateLabel =
          if builtins.isFunction cfg.template
          then cfg.nameSpace
          else "${cfg.nameSpace}-${lib.strings.toLower cfg.template}";
      in
      listToAttrs (
        map (idx: {
          name = "${templateLabel}-${toString idx}";
          value =
            let
              name = "${templateLabel}-${toString idx}";
            in
            {
              autoStart = true;
              privateNetwork = true;
              hostAddress = cfg.hostAddress;
              localAddress = "${cfg.subnet}.${toString (idx + 1)}";
              config =
                if builtins.isFunction cfg.template
                then cfg.template idx
                else mkContainerSystem { inherit name idx; templateName = cfg.template; };
            };
        }) (range 1 cfg.size)
      );
  };
}
