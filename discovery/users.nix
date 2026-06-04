{ lib }:
let
  inherit (builtins)
    pathExists
    attrNames
    foldl'
    readDir
    match
    elemAt
    ;
  inherit (lib) filterAttrs splitString removeSuffix mapAttrsToList concatMap;
  metaLib = import ./meta.nix { };
in
{
  # Parse user configs to create a host -> users mapping
  getUserHostMap =
    path:
    if !(pathExists path) then
      { }
    else
      let
        items = readDir path;
        
        # 1. Old way: user@host.nix
        files = filterAttrs (n: type: type == "regular" && (match ".*@.*\\.nix" n != null)) items;
        pairs1 = mapAttrsToList (n: _: 
          let
            parts = splitString "@" (removeSuffix ".nix" n);
          in
            { user = elemAt parts 0; host = elemAt parts 1; filename = n; }
        ) files;

        # 2. Directory way: user@host/default.nix
        dirsWithAt = filterAttrs (n: type: type == "directory" && (match ".*@.*" n != null)) items;
        pairs2 = concatMap (n: 
          if pathExists (path + "/${n}/default.nix") then
            let
              parts = splitString "@" n;
            in
              [ { user = elemAt parts 0; host = elemAt parts 1; filename = "${n}/default.nix"; } ]
          else
            [ ]
        ) (attrNames dirsWithAt);

        # 3. Host/User way: host/user.nix
        hostDirs = filterAttrs (n: type: type == "directory" && n != "profiles" && (match ".*@.*" n == null)) items;
        pairs3 = concatMap (host: 
          let
            hostItems = readDir (path + "/${host}");
            userFiles = filterAttrs (n: type: type == "regular" && (match ".*\\.nix" n != null) && n != "default.nix") hostItems;
          in
            mapAttrsToList (n: _:
              { user = removeSuffix ".nix" n; inherit host; filename = "${host}/${n}"; }
            ) userFiles
        ) (attrNames hostDirs);

        allPairs = pairs1 ++ pairs2 ++ pairs3;

        validPairs = builtins.filter (entry:
          let
            metaFile1 = path + "/${entry.user}@${entry.host}/meta.nix";
            metaFile2 = path + "/${entry.host}/meta.nix";
            metaFile = if pathExists metaFile1 then metaFile1
                       else if pathExists metaFile2 then metaFile2
                       else null;
          in
          !(metaLib.isBroken metaFile)
        ) allPairs;
      in
      foldl' (
        acc: entry:
        acc // {
          "${entry.host}" = (acc.${entry.host} or [ ]) ++ [ { inherit (entry) user filename; } ];
        }
      ) { } validPairs;
}
