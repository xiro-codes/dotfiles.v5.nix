{ inputs, lib, ... }:
let

  systemDir = ../systems;
  systemModulesDir = ../modules/system;
  homeDir = ../home;
  homeModulesDir = ../modules/home;
  packageDir = ../packages;
in
{
  perSystem = { config, pkgs, system, ... }:
    let
      discoverPackages =
        path:
        let
          contents = builtins.readDir path;
          packageDirs = builtins.filter
            (
              name: contents.${name} == "directory" && builtins.pathExists (path + "/${name}/default.nix")
            )
            (builtins.attrNames contents);
        in
        builtins.listToAttrs (
          map
            (name: {
              inherit name;
              value = inputs.nixpkgs.legacyPackages.x86_64-linux.callPackage (path + "/${name}/default.nix") {
                inherit inputs;
              };
            })
            packageDirs
        );
    in
    {
      packages = discoverPackages packageDir;
    };
  flake =
    let
      inherit (inputs.nixpkgs.lib) attrNames filterAttrs nixosSystem;
      discoverModules =
        path:
        if builtins.pathExists path then
          let
            dirs = attrNames (filterAttrs (_: type: type == "directory") (builtins.readDir path));
            validDirs = builtins.filter (name: builtins.pathExists (path + "/${name}/default.nix")) dirs;
          in
          builtins.listToAttrs (
            map
              (name: {
                name = name;
                value = import (path + "/${name}/default.nix");
              })
              validDirs
          )
        else
          { };

      mkOverlayFromDir =
        path: final: prev:
        let
          contents = builtins.readDir path;
          packageDirs = builtins.filter
            (
              name: contents.${name} == "directory" && builtins.pathExists (path + "/${name}/default.nix")
            )
            (builtins.attrNames contents);
        in
        builtins.listToAttrs (
          map
            (name: {
              inherit name;
              value = final.callPackage (path + "/${name}/default.nix") { inherit inputs; };
            })
            packageDirs
        );


      getHosts =
        path:
        if builtins.pathExists path then
          attrNames (filterAttrs (_: type: type == "directory") (builtins.readDir path))
        else
          [ ];


      discoveredSystemModules = discoverModules systemModulesDir;
      discoveredHomeModules = discoverModules homeModulesDir;

      hostNames = getHosts systemDir;

      homeFiles =
        if builtins.pathExists homeDir then
          attrNames
            (
              filterAttrs (n: type: type == "regular" && builtins.match ".*@.*\\.nix" n != null) (
                builtins.readDir homeDir
              )
            )
        else
          [ ];
      hostToUsersMap = builtins.foldl'
        (
          acc: filename:
            let
              namePart = lib.removeSuffix ".nix" filename;
              parts = lib.splitString "@" namePart;
              user = builtins.elemAt parts 0;
              host = builtins.elemAt parts 1;
            in
            acc // { "${host}" = (acc."${host}" or [ ]) ++ [ user ]; }
        )
        { }
        homeFiles;

    in
    {
      nixosModules = discoveredSystemModules;
      homeModules = discoveredHomeModules;

      nixosConfigurations = builtins.listToAttrs (
        map
          (name: {
            name = name;
            value = nixosSystem {
              specialArgs = {
                inherit inputs;
                currentHostName = name;
                currentHostUsers = hostToUsersMap."${name}" or [ ];
              };
              modules = [
                (systemDir + "/${name}/configuration.nix")
                inputs.home-manager.nixosModules.home-manager

                {
                  networking.hostName = name;
                  programs.nh = {
                    enable = true;
                    flake = "/etc/nixos";
                  };
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.overwriteBackup = true;
                  home-manager.backupFileExtension = ".bk";
                  home-manager.sharedModules = [
                    inputs.nixvim.homeModules.nixvim
                    inputs.stylix.homeModules.stylix
                    inputs.caelestia-shell.homeManagerModules.default
                  ]
                  ++ builtins.attrValues discoveredHomeModules;
                  home-manager.users = builtins.listToAttrs (
                    map
                      (username: {
                        name = username;
                        value = import (homeDir + "/${username}@${name}.nix");
                      })
                      (hostToUsersMap."${name}" or [ ])
                  );
                }
              ]
              ++ (builtins.attrValues discoveredSystemModules);
            };
          })
          hostNames
      );

      overlays.default = mkOverlayFromDir packageDir;

      homeConfigurations = builtins.listToAttrs (
        map
          (
            filename:
            let
              namePart = lib.removeSuffix ".nix" filename;
              parts = lib.splitString "@" namePart;
              user = builtins.elemAt parts 0;

            in
            {
              name = namePart;
              value = inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
                extraSpecialArgs = { inherit inputs; };
                modules = [
                  (homeDir + "/${filename}")
                  {
                    home.username = user;
                    home.homeDirectory = "/home/${user}";
                  }
                ]
                ++ (builtins.attrValues discoveredHomeModules);
              };
            }
          )
          homeFiles
      );
    };
}
