{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix.url = "github:danth/stylix";
    #flake-parts-website.url = "github:hercules-ci/flake.parts-website";
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
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./parts/discovery.v2.nix
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          devShells = {
            default = pkgs.callPackage ./shells/default/default.nix { inherit pkgs; };
          };
          packages.installer-iso = inputs.nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            format = "install-iso";
            specialArgs = { inherit inputs; };
            modules = [
              inputs.self.nixosModules.cache
              inputs.self.nixosModules.settings
              {
                local = {
                  cache.enable = true;
                  settings.enable = true;
                };
                imports = [
                  "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                ];
                users.motd = ''
                  Custom NixOS Installer

                  sudo install-system <hostname> <user> <password> [disk]
                '';

                environment.etc."dotfiles-src".source = builtins.path {
                  path = inputs.self.outPath;
                  name = "dotfiles-git-src";
                  filter = path: type: true;
                };
                environment.systemPackages =
                  with pkgs;
                  [
                    python3
                    git
                    parted
                    util-linux
                  ]
                  ++ [
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
