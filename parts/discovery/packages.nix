{ inputs, fs }:
let
  inherit (builtins) listToAttrs map;
in
{
  # Build packages from discovered directories
  mkPackages =
    path: system:
    let
      names = fs.getValidSubdirs path;
    in
    listToAttrs (
      map
        (name: {
          inherit name;
          value = inputs.nixpkgs.legacyPackages.${system}.callPackage (path + "/${name}/default.nix") {
            inherit inputs;
          };

        })
        names
    );
}
