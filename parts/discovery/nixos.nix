{ inputs
, lib
, paths
, hostToUsersMap
, discoveredSystemModules
, discoveredHomeModules
, globalNixosModules
, globalHomeModules
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
  genConfigs = hosts:
    listToAttrs (
      map
        (host: {
          name = host.name;
          value = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              currentHostName = host.name;
              currentHostUsers = map (u: u.user) (hostToUsersMap.${host.name} or [ ]);
            };
            modules = globalNixosModules ++ [
              (host.path + "/configuration.nix")
              ({
                networking.hostName = host.name;
                local.secrets.enable = true;
                home-manager = {
                  backupFileExtension = "backup";
                  backupCommand = "${inputs.nixpkgs.legacyPackages.x86_64-linux.trash-cli}/bin/trash";
                  extraSpecialArgs = { inherit inputs; };
                  sharedModules = (attrValues discoveredHomeModules) ++ globalHomeModules ++ [ ];
                  users = listToAttrs (
                    map
                      (u: {
                        name = u.user;
                        value = import (paths.home + "/${u.filename}");
                      })
                      (hostToUsersMap.${host.name} or [ ])
                  );

                };
              })
            ]
              ++ (attrValues discoveredSystemModules);

          };
        })
        hosts
    );

  findHosts = dir:
    if pathExists dir then
      attrNames
        (filterAttrs
          (name: type:
            type == "directory"
            && pathExists (dir + "/${name}/configuration.nix")
            && pathExists (dir + "/${name}/hardware-configuration.nix")
          )
          (readDir dir))
    else
      [ ];

  topLevelHosts = map (name: { inherit name; path = paths.systems + "/${name}"; }) (findHosts paths.systems);
  containerHosts = map (name: { inherit name; path = paths.systems + "/containers/${name}"; }) (findHosts (paths.systems + "/containers"));
in
{
  hosts = genConfigs topLevelHosts;
  containers = genConfigs containerHosts;
}
