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
      # Filter out broken modules based on meta.nix
      validNames = builtins.filter (name: 
        let
          metaFile = path + "/${name}/meta.nix";
          meta = if builtins.pathExists metaFile then import metaFile else { broken = false; };
        in
        !meta.broken
      ) names;
    in
    listToAttrs (
      map
        (name: {
          inherit name;
          value = import (path + "/${name}/default.nix");
        })
        validNames
    );
}
