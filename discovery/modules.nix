{ fs }:
let
  inherit (builtins)
    listToAttrs
    map
    concatLists
    pathExists
    filter
    isAttrs
    attrValues
    ;
  metaLib = import ./meta.nix { };
in
{
  # Build module attribute set from discovered directories
  mkModules =
    path:
    let
      # Directories that contain a module.nix (top-level modules)
      topLevelNames = fs.getDirsWith path [ "module.nix" ];

      # All directories in the path
      allDirs = fs.getDirs path;

      # Supermodules/Hubs are directories that are NOT modules themselves (no module.nix)
      hubs = filter (d: !(pathExists (path + "/${d}/module.nix"))) allDirs;

      # Recursively find modules in subdirectories
      findModules = prefix: dir:
        let
          subdirs = fs.getDirs dir;
          modulesHere = filter (d: pathExists (dir + "/${d}/module.nix")) subdirs;
          hubsHere = filter (d: !(pathExists (dir + "/${d}/module.nix"))) subdirs;
          
          # Convert modules in current directory to name-value pairs
          localPairs = map (name: {
            name = if prefix == "" then name else "${prefix}/${name}";
            value = if metaLib.isBroken (dir + "/${name}/meta.nix") then {} else dir + "/${name}/module.nix";
          }) modulesHere;
          
          # Recursively find in hubs
          nestedPairs = concatLists (map (hub: findModules (if prefix == "" then hub else "${prefix}/${hub}") (dir + "/${hub}")) hubsHere);
        in
        localPairs ++ nestedPairs;

      # Find all modules in hubs
      hubModules = concatLists (map (hub: findModules hub (path + "/${hub}")) hubs);

      topLevelModules = map (name: {
        inherit name;
        value = if metaLib.isBroken (path + "/${name}/meta.nix") then {} else path + "/${name}/module.nix";
      }) topLevelNames;
    in
    listToAttrs (topLevelModules ++ hubModules);
}
