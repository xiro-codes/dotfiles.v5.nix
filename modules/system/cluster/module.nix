{
  config,
  lib,
  inputs,
  self,
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
  inherit (lib) toLower;

  cfg = config.local.cluster;

  # Re-use the discovery utilities rather than duplicating them.
  paths = import (self.outPath + "/discovery/paths.nix") self.outPath;
  usersLib = import (self.outPath + "/discovery/users.nix") { inherit lib; };
  hostToUsersMap = usersLib.getUserHostMap paths.home;

  # Mirrors flake.nix globals.
  globalNixosModules = [
    {
      imports = [
        (self.outPath + "/modules/system/bootloader")
        (self.outPath + "/modules/system/disks")
        (self.outPath + "/modules/system/network")
        (self.outPath + "/modules/system/nix-core-settings")
        (self.outPath + "/modules/system/secrets")
        (self.outPath + "/modules/system/security")
        (self.outPath + "/modules/system/user-manager")
        (self.outPath + "/modules/system/localization")
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.gog-nix.nixosModules.gog
        inputs.rocket-blog.nixosModules.default
        inputs.silentsddm.nixosModules.default
        inputs.harmonia.nixosModules.harmonia
        inputs.impermanence.nixosModules.impermanence
        inputs.determinate.nixosModules.default
        inputs.nix-topology.nixosModules.default
        inputs.nix-compose.nixosModules.daemon
      ];
    }
  ];
  globalHomeModules = [
    {
      imports = [
        inputs.fuchsia-nix.homeModules.default
        inputs.sops-nix.homeModules.sops
        inputs.caelestia-shell.homeManagerModules.default
        inputs.nixvim.homeModules.nixvim
        inputs.stylix.homeModules.stylix
      ];
    }
  ];

  # Builds a fully-featured container config for a named template, identical to
  # what genConfigs in parts/discovery/nixos.nix produces for a regular system.
  mkContainerSystem =
    {
      name,
      idx,
      templateName,
    }:
    let
      templateUsers = hostToUsersMap.${templateName} or [ ];
    in
    { ... }:
    {
      imports =
        globalNixosModules
        ++ [
          (paths.systems + "/containers/${templateName}/configuration.nix")
          {
            networking.hostName = name;
            local.secrets.enable = true;
          }
        ];
      _module.args = {
        inherit self inputs;
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

  config =
    let
      templateLabel =
        if builtins.isFunction cfg.template then
          cfg.nameSpace
        else
          "${cfg.nameSpace}-${toLower cfg.template}";

    in
    mkIf cfg.enable {
      local.shared.cluster = cfg;
      containers = listToAttrs (
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
              specialArgs = { inherit self inputs; };
              config =
                if builtins.isFunction cfg.template then
                  cfg.template idx
                else
                  mkContainerSystem {
                    inherit name idx;
                    templateName = cfg.template;
                  };
            };
        }) (range 1 cfg.size)
      );
    };
}
