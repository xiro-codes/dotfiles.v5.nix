{ inputs, ... }:
let
  metaLib = import ./discovery/meta.nix { };
in
{
  flake = {
    schemas = inputs.flake-schemas.schemas // {
      nixosModules = inputs.flake-schemas.schemas.nixosModules // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "NixOS module" (../modules/system + "/${name}/meta.nix");
          }) output;
        };
      };
      homeModules = inputs.flake-schemas.schemas.homeModules // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "Home Manager module" (../modules/home + "/${name}/meta.nix");
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
      homeConfigurations = inputs.flake-schemas.schemas.homeConfigurations // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what =
              let
                parts = builtins.split "@" name;
                user = builtins.elemAt parts 0;
                host = builtins.elemAt parts 2;
                
                metaFile1 = ../home + "/${name}/meta.nix";
                metaFile2 = ../home + "/${host}/meta.nix";
                
                metaFile = if builtins.pathExists metaFile1 then metaFile1
                           else if builtins.pathExists metaFile2 then metaFile2
                           else null;
              in
              metaLib.getWhatWithDescription "Home Manager configuration" metaFile;
          }) output;
        };
      };
      nixosConfigurations = inputs.flake-schemas.schemas.nixosConfigurations // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "NixOS configuration" (../systems + "/${name}/meta.nix");
          }) output;
        };
      };
      nixosContainers = {
        version = 1;
        doc = "NixOS container configurations";
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "NixOS container" (../systems/containers + "/${name}/meta.nix");
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
}
