{
  inputs,
  lib,
  fs,
  paths,
  hostToUsersMap,
  discoveredSystemModules,
  discoveredHomeModules,
  globalNixosModules,
  globalHomeModules,
  discoveredOverlays,
}:
let
  inherit (builtins)
    pathExists
    readDir
    attrNames
    listToAttrs
    map
    attrValues
    ;
  inherit (lib) filterAttrs;
in
let
  # Generate nixosConfigurations for all discovered hosts and containers
  metaLib = import ./meta.nix { };

  genConfigs =
    hosts:
    listToAttrs (
      map (host:
        let
          isUnstable = metaLib.isUnstable (host.path + "/meta.nix");
          pkgSource = if isUnstable then inputs.nixpkgs-unstable else inputs.nixpkgs;
        in {
        name = host.name;
        value = pkgSource.lib.nixosSystem {
          specialArgs = {
            self = inputs.self;
            inherit inputs;
            currentHostName = host.name;
            currentHostUsers = map (u: u.user) (hostToUsersMap.${host.name} or [ ]);
          };
          modules =
            globalNixosModules
            ++ (attrValues discoveredSystemModules)
            ++ [
              (host.path + "/configuration.nix")
              ({ pkgs, ... }: {
                nixpkgs.overlays = attrValues discoveredOverlays;
                networking.hostName = host.name;
                local.secrets.enable = true;
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  # TODO: CROSS-COMPILATION SMELL FIXED: 
                  # This was previously hardcoded to `inputs.nixpkgs.legacyPackages.x86_64-linux.trash-cli`.
                  # By wrapping this block in a `{ pkgs, ... }:` function, we can dynamically use the host's architecture.
                  backupCommand = "${pkgs.trash-cli}/bin/trash";
                  extraSpecialArgs = {
                    self = inputs.self;
                    inherit inputs;
                  };
                  sharedModules = (attrValues discoveredHomeModules) ++ globalHomeModules ++ [ ];
                  users = listToAttrs (
                    map (u: {
                      name = u.user;
                      value = import (paths.home + "/${u.filename}");
                    }) (hostToUsersMap.${host.name} or [ ])
                  );
                };
              })
            ];
        };
      }) hosts
    );

  findHosts =
    dir:
    fs.getDirsWith dir [
      "configuration.nix"
      "hardware-configuration.nix"
    ];

  topLevelHosts = builtins.filter (h: !(metaLib.isBroken (h.path + "/meta.nix"))) (map (name: {
    inherit name;
    path = paths.systems + "/${name}";
  }) (findHosts paths.systems));
  
  containerHosts = builtins.filter (h: !(metaLib.isBroken (h.path + "/meta.nix"))) (map (name: {
    inherit name;
    path = paths.systems + "/containers/${name}";
  }) (findHosts (paths.systems + "/containers")));
in
{
  hosts = genConfigs topLevelHosts;
  containers = genConfigs containerHosts;
}
