{
  description = "NixOS Dotfiles (v5) with automated discovery engine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixarr.url = "github:nix-media-server/nixarr";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    rocket-blog.url = "github:xiro-codes/rocket_blog";
    nvim-nix.url = "github:xiro-codes/nvim.nix";
    harmonia.url = "github:nix-community/harmonia";
    fuchsia-nix = {
      url = "github:xiro-codes/fuchsia.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    silentsddm = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gog-nix = {
      url = "github:xiro-codes/gog.nix";
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
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
    nix-topology.url = "github:oddlama/nix-topology";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    nix-compose = {
      url = "github:xiro-codes/nix-compose";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        (import ./schemas.nix self.outPath)
        (import ./discovery {
          globalNixosModules = [
            { _module.args.flake-inputs = inputs; }
            {
              imports = [
                ./modules/system/bootloader
                ./modules/system/disks
                ./modules/system/network
                ./modules/system/nix-core-settings
                ./modules/system/secrets
                ./modules/system/security
                ./modules/system/user-manager
                ./modules/system/localization
                inputs.disko.nixosModules.disko
                inputs.sops-nix.nixosModules.sops
                inputs.home-manager.nixosModules.home-manager
                inputs.nix-flatpak.nixosModules.nix-flatpak
                inputs.gog-nix.nixosModules.gog
                inputs.rocket-blog.nixosModules.default
                inputs.silentsddm.nixosModules.default
                inputs.harmonia.nixosModules.harmonia
                inputs.impermanence.nixosModules.impermanence
                inputs.determinate.nixosModules.default
                inputs.nix-topology.nixosModules.default
                inputs.nix-compose.nixosModules.daemon
                inputs.nixarr.nixosModules.default
              ];
            }
          ];
          globalHomeModules = [
            {
              imports = [
                inputs.fuchsia-nix.homeModules.default
                inputs.sops-nix.homeModules.sops
                inputs.caelestia-shell.homeManagerModules.default
                inputs.nixvim.homeModules.nixvim
                inputs.stylix.homeModules.stylix
              ];
            }
          ];
        })
      ];
      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt-tree;
          packages = inputs.nvim-nix.packages.${system};
          # topology.modules = [
          #   ./topology.nix
          # ];
        };
    };
}
