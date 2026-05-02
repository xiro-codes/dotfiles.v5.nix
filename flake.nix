{
  description = "NixOS Dotfiles (v5) with automated discovery engine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    deploy-rs.url = "github:serokell/deploy-rs";
    nix-topology.url = "github:oddlama/nix-topology";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
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

      flake = {
        schemas = flake-schemas.schemas // {
          nixosModules = flake-schemas.schemas.nixosModules // {
            inventory = output: {
              children = builtins.mapAttrs (name: value: {
                what =
                  "NixOS module"
                  + (
                    let
                      metaFile = ./modules/system + "/${name}/meta.nix";
                    in
                    if builtins.pathExists metaFile then
                      let
                        meta = import metaFile;
                      in
                      if meta ? description then ": ${meta.description}" else ""
                    else
                      ""
                  );
              }) output;
            };
          };
          homeModules = flake-schemas.schemas.homeModules // {
            inventory = output: {
              children = builtins.mapAttrs (name: value: {
                what =
                  "Home Manager module"
                  + (
                    let
                      metaFile = ./modules/home + "/${name}/meta.nix";
                    in
                    if builtins.pathExists metaFile then
                      let
                        meta = import metaFile;
                      in
                      if meta ? description then ": ${meta.description}" else ""
                    else
                      ""
                  );
              }) output;
            };
          };
          deploy = {
            version = 1;
            doc = "deploy-rs deployment configurations";
            inventory = output: {
              children = builtins.mapAttrs (name: value: {
                what = "deployment node";
              }) output.nodes;
            };
          };
          nixosContainers = {
            version = 1;
            doc = "NixOS container configurations";
            inventory = output: {
              children = builtins.mapAttrs (name: value: {
                what = "NixOS container";
              }) output;
            };
          };
          topology = {
            version = 1;
            doc = "nix-topology configuration";
            inventory = output: {
              children = builtins.mapAttrs (name: value: {
                what = "topology node";
              }) output;
            };
          };
        };
      };

      imports = [
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
