{ inputs
, lib
, paths
, hostToUsersMap
, discoveredSystemModules
, discoveredHomeModules
,
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
          attrNames (filterAttrs
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
            modules = [
              (paths.systems + "/${name}/configuration.nix")
              inputs.disko.nixosModules.disko
              inputs.sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              ({
                networking.hostName = name;
                local.secrets.enable = true;
                home-manager = {
                  extraSpecialArgs = { inherit inputs; };
                  sharedModules = (attrValues discoveredHomeModules) ++ [
                    inputs.sops-nix.homeModules.sops
                    inputs.caelestia-shell.homeManagerModules.default
                    inputs.nixvim.homeModules.nixvim
                    inputs.stylix.homeModules.stylix
                  ];
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
