{ fs }:
let
  inherit (builtins) listToAttrs map;
  metaLib = import ./meta.nix { };
in
{
  # Build module attribute set from discovered directories
  mkModules =
    path:
    let
      names = fs.getValidSubdirs path;
      # Filter out broken modules based on meta.nix
      validNames = builtins.filter (
        name:
        !(metaLib.isBroken (path + "/${name}/meta.nix"))
      ) names;
    in
    listToAttrs (
      map (name: {
        inherit name;
        value = path + "/${name}";
      }) validNames
    );
}
