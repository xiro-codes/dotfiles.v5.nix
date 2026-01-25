{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{flake-parts, ...}:
    flake-parts.lib.mkFlake { inherit inputs;} {
      systems = ["x86_64-linux"]; 
      imports = [
        ./parts/discovery.nix
      ];
      perSystem = { config, pkgs, ...}: {
        devShells = { default = pkgs.callPackage ./shells/default/default.nix { inherit pkgs; }; };
        packages.iso = inputs.nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "install-iso";
          specialArgs = { inherit inputs; };
          modules = [
            {
              imports = [
                "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ];
              users.motd = ''
                Custom NixOS Installer

                sudo install-system <hostname> <desktop> <user> <password> [disk]
                '';
              environment.etc."dotfiles-src".source = builtins.path {
                path = ./.;
                name = "dotfiles-git-src";
                filter = path: type: true;
              };
              environment.systemPackages = [
                inputs.self.packages.x86_64-linux.install-system
              ];
              nixpkgs.config.allowUnfree = true;

              networking.hostName = "installer"; 
            }
          ];
        };
      };
    };
}
