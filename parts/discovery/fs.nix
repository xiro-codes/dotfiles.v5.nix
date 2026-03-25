{ lib }:
let
  inherit (builtins)
    pathExists
    readDir
    filter
    attrNames
    ;
in
{
  # Get all directories in a path
  getDirs =
    path:
    if pathExists path then
      let
        contents = readDir path;
      in
      filter (name: contents.${name} == "directory") (attrNames contents)
    else
      [ ];

  # Get directories that contain a default.nix file
  getValidSubdirs =
    path:
    if pathExists path then
      let
        contents = readDir path;
      in
      filter (name: contents.${name} == "directory" && pathExists (path + "/${name}/default.nix")) (
        attrNames contents
      )
    else
      [ ];
}
