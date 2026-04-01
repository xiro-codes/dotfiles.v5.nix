{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    deploy-rs.url = "github:serokell/deploy-rs";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inputs-nix = {
      url = "github:xiro-codes/inputs.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{ self, deploy-rs, flake-parts, inputs-nix, nixpkgs-unstable, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        (import ./parts/discovery {
          globalNixosModules = [ inputs-nix.nixosModules.default ];
          globalHomeModules = [ inputs-nix.homeModules.default ];
        })
      ];
    };
}
