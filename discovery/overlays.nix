{ fs, lib, paths }:
let
  inherit (builtins)
    readDir
    pathExists
    listToAttrs
    map
    attrNames
    filter
    ;
  inherit (lib) removeSuffix hasSuffix;
  
  # Read all files in the overlays directory
  overlayFiles = 
    if pathExists paths.overlays then
      let
        contents = readDir paths.overlays;
      in
        # .nix files (excluding default.nix)
        filter (name: contents.${name} == "regular" && hasSuffix ".nix" name && name != "default.nix") (attrNames contents)
        ++ 
        # Directories with default.nix
        filter (name: contents.${name} == "directory" && pathExists (paths.overlays + "/${name}/default.nix")) (attrNames contents)
    else
      [ ];
in
{
  mkOverlays = listToAttrs (map (name: {
    name = removeSuffix ".nix" name;
    value = import (paths.overlays + "/${name}");
  }) overlayFiles);
}
