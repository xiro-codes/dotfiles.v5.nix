{
  description = "NixOS Dotfiles (v5) with automated discovery engine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    deploy-rs.url = "github:serokell/deploy-rs";
    nix-topology.url = "github:oddlama/nix-topology";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    inputs-nix = {
      url = "github:xiro-codes/inputs.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      flake-schemas,
      inputs-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./parts/schemas.nix
        inputs.nix-topology.flakeModule
        (import ./parts/discovery {
          globalNixosModules = [
            inputs.determinate.nixosModules.default
            inputs-nix.nixosModules.default
            inputs.nix-topology.nixosModules.default
          ];
          globalHomeModules = [ inputs-nix.homeModules.default ];
        })
      ];
      perSystem =
        { config, pkgs, ... }:
        {
          formatter = pkgs.nixfmt-tree;
          topology.modules = [
            ./topology.nix
          ];
        };
    };
}
