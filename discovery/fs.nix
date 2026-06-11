{ lib }:
let
  inherit (builtins)
    pathExists
    readDir
    filter
    attrNames
    all
    ;
  metaLib = import ./meta.nix { };

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

  # Get directories that contain all specified files
  getDirsWith = path: requiredFiles:
    if builtins ? getDirsWithCached
    then builtins.getDirsWithCached path requiredFiles
    else filter (name:
      let dir = path + "/${name}";
      in all (f: pathExists (dir + "/${f}")) requiredFiles
    ) (getDirs path);
in
{
  inherit getDirs getDirsWith;

  # Get directories that contain a default.nix file
  getValidSubdirs = path: getDirsWith path [ "default.nix" ];
}
