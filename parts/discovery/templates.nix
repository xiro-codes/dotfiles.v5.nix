{ fs }:
let
  inherit (builtins) listToAttrs map;
in
{
  # Build template attribute set from discovered directories
  mkTemplates =
    path:
    let
      names = fs.getDirs path;
    in
    listToAttrs (
      map
        (name: {
          inherit name;
          value = {
            path = path + "/${name}";
            description = "System templates";
          };
        })
        names
    );
}
