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
      homeConfigurations = inputs.flake-schemas.schemas.homeConfigurations // {
        inventory = output: {
          children = builtins.mapAttrs (name: value: {
            what =
              "Home Manager configuration"
              + (
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
                if metaFile != null then
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
