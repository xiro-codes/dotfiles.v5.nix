{
  description = "NixOS Dotfiles (v5) with automated discovery engine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    inputs-nix = {
      url = "github:xiro-codes/inputs.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fuchsia-cursor.url = "git+file:///home/tod/Projects/fuchsia-cursor";
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
        inputs-nix.inputs.nix-topology.flakeModule
        (inputs-nix.discovery {
          globalNixosModules = [
            { _module.args.flake-inputs = inputs; }
            inputs-nix.inputs.determinate.nixosModules.default
            inputs-nix.nixosModules.default
            inputs-nix.inputs.nix-topology.nixosModules.default
          ];
          globalHomeModules = [
            inputs-nix.homeModules.default
            inputs.fuchsia-cursor.homeModules.default
          ];
        })
      ];
      perSystem =
        { config, pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
          topology.modules = [
            ./topology.nix
          ];
        };
    };
}
