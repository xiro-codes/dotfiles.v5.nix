base: { inputs, ... }:
let
  metaLib = import ./discovery/meta.nix { };
  baseStr = builtins.toString base;
in
{
  flake = {
    schemas = builtins.removeAttrs inputs.flake-schemas.schemas [ "templates" ] // {
      nixosModules = inputs.flake-schemas.schemas.nixosModules // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "NixOS module" (baseStr + "/modules/system/${name}/meta.nix");
          }) output;
        };
      };
      homeModules = inputs.flake-schemas.schemas.homeModules // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "Home Manager module" (baseStr + "/modules/home/${name}/meta.nix");
          }) output;
        };
      };
      deploy = {
        version = 1;
        doc = "deploy-rs deployment configurations";
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "deployment node" (baseStr + "/systems/${name}/meta.nix");
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
                
                metaFile1 = baseStr + "/home/${name}/meta.nix";
                metaFile2 = baseStr + "/home/${host}/meta.nix";
                
                metaFile = if builtins.pathExists metaFile1 then metaFile1
                           else if builtins.pathExists metaFile2 then metaFile2
                           else null;
              in
              metaLib.formatWhat "Home Manager configuration" (metaLib.getDescription metaFile) ((metaLib.isBroken metaFile) || (metaLib.isBroken (baseStr + "/systems/${host}/meta.nix")));
          }) output;
        };
      };
      nixosConfigurations = inputs.flake-schemas.schemas.nixosConfigurations // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "NixOS configuration" (baseStr + "/systems/${name}/meta.nix");
          }) output;
        };
      };
      nixosContainers = {
        version = 1;
        doc = "NixOS container configurations";
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what = metaLib.getWhatWithDescription "NixOS container" (baseStr + "/systems/containers/${name}/meta.nix");
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
