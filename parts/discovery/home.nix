{ inputs
, lib
, paths
, hostToUsersMap
, discoveredHomeModules
,
}:
let
  inherit (builtins)
    listToAttrs
    map
    attrValues
    foldl'
    ;
in
{
  # Generate standalone homeConfigurations for each user@host combination
  mkHomeConfigurations =
    let
      # Flatten hostToUsersMap into a list of { user, host, filename } entries
      userHostPairs = foldl'
        (acc: host:
          acc ++ (map (u: u // { inherit host; }) (hostToUsersMap.${host} or [ ]))
        )
        [ ]
        (builtins.attrNames hostToUsersMap);
    in
    listToAttrs (
      map
        (entry: {
          # Name format: user@host
          name = "${entry.user}@${entry.host}";
          value = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = { inherit inputs; };
            modules = [
              (paths.home + "/${entry.filename}")
              {
                home.username = entry.user;
                home.homeDirectory = "/home/${entry.user}";
                nix.package = inputs.nixpkgs.legacyPackages.x86_64-linux.nix;
              }
            ] ++ (attrValues discoveredHomeModules) ++ [
              inputs.sops-nix.homeModules.sops
              inputs.caelestia-shell.homeManagerModules.default
              inputs.nixvim.homeModules.nixvim
              inputs.stylix.homeModules.stylix
            ];
          };
        })
        userHostPairs
    );
}
