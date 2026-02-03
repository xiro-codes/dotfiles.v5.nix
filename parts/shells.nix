{ inputs, lib, ... }:
let
  paths = import ./discovery/paths.nix;
  
  # Add shells path to the paths
  shellsPath = ../../shells;
  
  inherit (builtins) readDir pathExists attrNames listToAttrs map;
  inherit (lib) filterAttrs;
in
{
  perSystem = { pkgs, system, ... }:
    let
      # Discover all shell directories
      shellDirs = 
        if pathExists shellsPath then
          attrNames (filterAttrs (_: type: type == "directory") (readDir shellsPath))
        else
          [ ];
      
      # Generate devShells for each discovered directory
      devShells = listToAttrs (
        map
          (name: {
            inherit name;
            value = pkgs.callPackage (shellsPath + "/${name}/default.nix") { 
              inherit pkgs inputs; 
            };
          })
          shellDirs
      );
    in
    {
      inherit devShells;
    };
}
