{ inputs, ... }:
{
  flake = {
    schemas = inputs.flake-schemas.schemas // {
      nixosModules = inputs.flake-schemas.schemas.nixosModules // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what =
              "NixOS module"
              + (
                let
                  metaFile = ../modules/system + "/${name}/meta.nix";
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
      homeModules = inputs.flake-schemas.schemas.homeModules // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what =
              "Home Manager module"
              + (
                let
                  metaFile = ../modules/home + "/${name}/meta.nix";
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
      nixosConfigurations = inputs.flake-schemas.schemas.nixosConfigurations // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what =
              "NixOS configuration"
              + (
                let
                  metaFile = ../systems + "/${name}/meta.nix";
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
      nixosContainers = {
        version = 1;
        doc = "NixOS container configurations";
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what =
              "NixOS container"
              + (
                let
                  metaFile = ../systems/containers + "/${name}/meta.nix";
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
