{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix.url = "github:danth/stylix";
    deploy-rs.url = "github:serokell/deploy-rs";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    gog-nix = {
      url = "github:xiro-codes/gog.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };
  outputs =
    inputs@{ self, deploy-rs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        (import ./parts/discovery {
          globalNixosModules = with inputs; [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak
          ];
          globalHomeModules = with inputs; [
            sops-nix.homeModules.sops
            caelestia-shell.homeManagerModules.default
            nixvim.homeModules.nixvim
            stylix.homeModules.stylix
          ];
        })
      ];
    };
}
