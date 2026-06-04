{ fs }:
let
  inherit (builtins) listToAttrs map filter pathExists;
in
{
  # Build template attribute set from discovered directories
  mkTemplates =
    path:
    let
      names = fs.getDirs path;
      validNames = filter (name: pathExists (path + "/${name}/flake.nix")) names;
    in
    listToAttrs (
      map (name: {
        inherit name;
        value = {
          path = path + "/${name}";
          description = "System templates";
        };
      }) validNames
    );
}
