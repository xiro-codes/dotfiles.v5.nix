{
  inputs,
  paths,
  fs,
}:
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
    fs.getDirsWith paths.systems [ "deploy.nix" ];
in
{
  # Generate deploy.nodes configuration for deploy-rs
  mkDeployNodes =
    let
      systems = getDeployableSystems;
    in
    listToAttrs (
      map (
        name:
        let
          deployConfig = import (paths.systems + "/${name}/deploy.nix");
        in
        {
          inherit name;
          value = {
            hostname = deployConfig.hostname;
            sshOpts = deployConfig.sshOpts or [ ];
            profiles.system = {
              user = deployConfig.user or "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.${name};
            };
          };
        }
      ) systems
    );
}
