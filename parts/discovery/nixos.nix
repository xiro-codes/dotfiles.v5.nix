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
{
  # Generate nixosConfigurations for all discovered hosts
  mkNixosConfigurations =
    let
      hosts =
        if pathExists paths.systems then
          attrNames
            (filterAttrs
              (name: type:
                type == "directory"
                && pathExists (paths.systems + "/${name}/configuration.nix")
                && pathExists (paths.systems + "/${name}/hardware-configuration.nix")
              )
              (readDir paths.systems))
        else
          [ ];
    in
    listToAttrs (
      map
        (name: {
          inherit name;
          value = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              currentHostName = name;
              currentHostUsers = map (u: u.user) (hostToUsersMap.${name} or [ ]);
            };
            modules = globalNixosModules ++ [
              (paths.systems + "/${name}/configuration.nix")
              ({
                networking.hostName = name;
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
                      (hostToUsersMap.${name} or [ ])
                  );

                };
              })
            ]
              ++ (attrValues discoveredSystemModules);

          };
        })
        hosts
    );
}
