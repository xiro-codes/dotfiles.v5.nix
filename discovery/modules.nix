{ fs }:
let
  inherit (builtins)
    listToAttrs
    map
    concatLists
    pathExists
    filter
    ;
  metaLib = import ./meta.nix { };
in
{
  # Build module attribute set from discovered directories
  mkModules =
    path:
    let
      # Directories that contain a default.nix (top-level modules)
      topLevelNames = fs.getValidSubdirs path;

      # All directories in the path
      allDirs = fs.getDirs path;

      # Hubs are directories that are NOT modules themselves (no default.nix)
      hubs = filter (d: !(pathExists (path + "/${d}/default.nix"))) allDirs;

      # Modules inside hubs (1 level deep)
      hubModules = concatLists (
        map (hub:
          let
            hubPath = path + "/${hub}";
            hubSubdirs = fs.getValidSubdirs hubPath;
          in
          map (name: {
            inherit name;
            value = hubPath + "/${name}";
          }) hubSubdirs
        ) hubs
      );

      topLevelModules = map (name: {
        inherit name;
        value = path + "/${name}";
      }) topLevelNames;
    in
    listToAttrs (topLevelModules ++ hubModules);
}
