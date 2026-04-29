{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    deploy-rs.url = "github:serokell/deploy-rs";
    nix-topology.url = "github:oddlama/nix-topology";
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
        inputs.nix-topology.flakeModule
        (import ./parts/discovery {
          globalNixosModules = [
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
            (
              { config, ... }:
              {
                # Base nix-topology configuration
              }
            )
          ];
        };
    };
}
