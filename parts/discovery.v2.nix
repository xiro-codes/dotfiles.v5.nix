{ inputs, lib, ... }:
let
  inherit (builtins)
    pathExists
    readDir
    filter
    attrNames
    listToAttrs
    foldl'
    attrValues
    ;
  inherit (lib) filterAttrs splitString;
  paths = {
    systems = ../systems;
    systemModules = ../modules/system;
    home = ../home;
    homeModules = ../modules/home;
    packages = ../packages;
    templates = ../templates;
  };
  getDirs =
    path:
    if pathExists path then
      let
        contents = readDir path;
      in
      filter (name: contents.${name} == "directory") (attrNames contents)
    else
      [ ];

  getValidSubdirs =
    path:
    if pathExists path then
      let
        contents = readDir path;
      in
      filter (name: contents.${name} == "directory" && pathExists (path + "/${name}/default.nix")) (
        attrNames contents
      )
    else
      [ ];
  mkPackages =
    path: system:
    let
      names = getValidSubdirs path;
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
  mkModules =
    path:
    let
      names = getValidSubdirs path;
    in
    listToAttrs (
      map
        (name: {
          inherit name;
          value = import (path + "/${name}/default.nix");
        })
        names
    );
  mkTemplates =
    path:
    let
      names = getDirs path;
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

  getUserHostMap =
    path:
    if !(pathExists path) then
      { }
    else
      let
        files = attrNames (
          filterAttrs (n: type: type == "regular" && (builtins.match ".*@.*\\.nix" n != null)) (
            builtins.readDir path
          )
        );
      in
      foldl'
        (
          acc: filename:
          let
            parts = splitString "@" (lib.removeSuffix ".nix" filename);
            user = builtins.elemAt parts 0;
            host = builtins.elemAt parts 1;
          in
          acc
          // {
            "${host}" = (acc.${host} or [ ]) ++ [{ inherit user filename; }];
          }
        )
        { }
        files;

  hostToUsersMap = getUserHostMap paths.home;
  discoveredSystemModules = mkModules paths.systemModules;
  discoveredHomeModules = mkModules paths.homeModules;
  discoveredTemplates = mkTemplates paths.templates;

in
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages = mkPackages paths.packages system;
    };
  flake = {
    nixosModules = discoveredSystemModules;
    homeModules = discoveredHomeModules;
    nixosConfigurations =
      let
        hosts =
          if pathExists paths.systems then
            attrNames (filterAttrs (_: type: type == "directory") (readDir paths.systems))
          else
            [ ];
      in
      listToAttrs (
        map
          (name: {
            inherit name;
            value = inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                currentHostName = name;
                currentHostUsers = map (u: u.user) (hostToUsersMap.${name} or [ ]);
              };
              modules = [
                (paths.systems + "/${name}/configuration.nix")
                inputs.disko.nixosModules.disko
                inputs.sops-nix.nixosModules.sops
                inputs.home-manager.nixosModules.home-manager
                ({
                  networking.hostName = name;
                  local.secrets.enable = true;
                  home-manager = {
                    extraSpecialArgs = { inherit inputs; };
                    sharedModules = (attrValues discoveredHomeModules) ++ [
                      inputs.sops-nix.homeModules.sops
                      inputs.caelestia-shell.homeManagerModules.default
                      inputs.nixvim.homeModules.nixvim
                      inputs.stylix.homeModules.stylix

                    ];
                    users = listToAttrs (
                      map
                        (u: {
                          name = u.user;
                          value = import (paths.home + "/${u.filename}");
                        })
                        (hostToUsersMap.${name} or [ ])
                    );

                  };
                })
              ]
              ++ (attrValues discoveredSystemModules);

            };
          })
          hosts
      );
    templates = discoveredTemplates;
    overlays.default = final: prev: mkPackages paths.packages final.system;
  };
}
