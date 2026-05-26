{
  description = "NixOS Dotfiles (v5) with automated discovery engine";

  inputs = {
    nixpkgs.url = "github:xiro-codes/nixpkgs/master";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    inputs-nix = {
      url = "github:xiro-codes/inputs.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      inputs-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        (inputs-nix.schemaBuilder inputs.self.outPath)
        (inputs-nix.discovery {
          globalNixosModules = [
            { _module.args.flake-inputs = inputs; }
            inputs-nix.nixosModules.default
          ];
          globalHomeModules = [
            inputs-nix.homeModules.default
          ];
        })
      ];
      perSystem =
        { config, pkgs, ... }:
        {
          formatter = pkgs.nixfmt-tree;
          # topology.modules = [
          #   ./topology.nix
          # ];
        };
    };
}
