{ lib, fs, paths }:
let
  inherit (builtins) readDir pathExists attrNames listToAttrs map;
  inherit (lib) filterAttrs;
in
{
  # Generate devShells for all discovered shell directories
  mkShells = { pkgs, inputs }:
    let
      # Discover all shell directories
      shellDirs = 
        if pathExists paths.shells then
          attrNames (filterAttrs (_: type: type == "directory") (readDir paths.shells))
        else
          [ ];
    in
    listToAttrs (
      map
        (name: {
          inherit name;
          value = pkgs.callPackage (paths.shells + "/${name}/default.nix") { 
            inherit pkgs inputs; 
          };
        })
        shellDirs
    );
}
