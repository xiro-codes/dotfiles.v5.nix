{ fs }:
let
  inherit (builtins) listToAttrs map;
in
{
  # Build module attribute set from discovered directories
  mkModules =
    path:
    let
      names = fs.getValidSubdirs path;
    in
    listToAttrs (
      map
        (name: {
          inherit name;
          value = import (path + "/${name}/default.nix");
        })
        names
    );
}
