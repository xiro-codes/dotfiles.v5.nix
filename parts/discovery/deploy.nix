{ inputs, paths }:
let
  inherit (builtins)
    pathExists
    readDir
    attrNames
    listToAttrs
    map
    ;
  inherit (inputs.nixpkgs.lib) filterAttrs;

  # Get all system directories that have a deploy.nix file
  getDeployableSystems =
    if pathExists paths.systems then
      let
        systemDirs = attrNames (filterAttrs (_: type: type == "directory") (readDir paths.systems));
        hasDeployConfig = name: pathExists (paths.systems + "/${name}/deploy.nix");
      in
      builtins.filter hasDeployConfig systemDirs
    else
      [ ];

in
{
  # Generate deploy.nodes configuration for deploy-rs
  mkDeployNodes =
    let
      systems = getDeployableSystems;
    in
    listToAttrs (
      map
        (name:
          let
            deployConfig = import (paths.systems + "/${name}/deploy.nix");
          in
          {
            inherit name;
            value = {
              hostname = deployConfig.hostname;
              profiles.system = {
                user = deployConfig.user or "root";
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.${name};
              };
            };
          }
        )
        systems
    );
}
