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
  inherit (lib) filterAttrs splitString removeSuffix;
in
{
  # Parse user@host.nix files to create a host -> users mapping
  getUserHostMap =
    path:
    if !(pathExists path) then
      { }
    else
      let
        files = attrNames (
          filterAttrs (n: type: type == "regular" && (match ".*@.*\\.nix" n != null)) (
            readDir path
          )
        );
      in
      foldl'
        (
          acc: filename:
          let
            parts = splitString "@" (removeSuffix ".nix" filename);
            user = elemAt parts 0;
            host = elemAt parts 1;
          in
          acc
          // {
            "${host}" = (acc.${host} or [ ]) ++ [{ inherit user filename; }];
          }
        )
        { }
        files;
}
