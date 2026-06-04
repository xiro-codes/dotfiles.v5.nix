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
      map (host: {
        name = host.name;
        value = inputs.nixpkgs.lib.nixosSystem {
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
              {
                networking.hostName = host.name;
                local.secrets.enable = true;
                home-manager = {
                  backupFileExtension = "backup";
                  backupCommand = "${inputs.nixpkgs.legacyPackages.x86_64-linux.trash-cli}/bin/trash";
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
              }
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

  topLevelHosts = map (name: {
    inherit name;
    path = paths.systems + "/${name}";
  }) (findHosts paths.systems);
  containerHosts = map (name: {
    inherit name;
    path = paths.systems + "/containers/${name}";
  }) (findHosts (paths.systems + "/containers"));
in
{
  hosts = genConfigs topLevelHosts;
  containers = genConfigs containerHosts;
}
