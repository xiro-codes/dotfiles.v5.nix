{ inputs, lib, ... }:
let
  # Import paths configuration
  paths = import ./paths.nix;

  # Import utility modules
  fs = import ./fs.nix { inherit lib; };
  packagesLib = import ./packages.nix { inherit inputs fs; };
  modulesLib = import ./modules.nix { inherit fs; };
  templatesLib = import ./templates.nix { inherit fs; };
  usersLib = import ./users.nix { inherit lib; };

  # Discover all components
  hostToUsersMap = usersLib.getUserHostMap paths.home;
  discoveredSystemModules = modulesLib.mkModules paths.systemModules;
  discoveredHomeModules = modulesLib.mkModules paths.homeModules;
  discoveredTemplates = templatesLib.mkTemplates paths.templates;

  # Import nixos configuration generator
  nixosLib = import ./nixos.nix {
    inherit
      inputs
      lib
      paths
      hostToUsersMap
      discoveredSystemModules
      discoveredHomeModules
      ;
  };

  # Import home-manager configuration generator
  homeLib = import ./home.nix {
    inherit
      inputs
      lib
      paths
      hostToUsersMap
      discoveredHomeModules
      ;
  };

in
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages = packagesLib.mkPackages paths.packages system;
    };

  flake = {
    nixosModules = discoveredSystemModules;
    homeModules = discoveredHomeModules;
    nixosConfigurations = nixosLib.mkNixosConfigurations;
    homeConfigurations = homeLib.mkHomeConfigurations;
    templates = discoveredTemplates;
    overlays.default = final: prev: packagesLib.mkPackages paths.packages final.system;
  };
}
