{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

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
    deploy-rs.url = "github:serokell/deploy-rs";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{ self, deploy-rs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./parts/discovery
      ];

      flake = {
        deploy.nodes = {
          Ruby = {
            hostname = "10.0.0.66";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.Ruby;
            };
          };
          Sapphire = {
            hostname = "10.0.0.67";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.Sapphire;
            };
          };
        };
      };

      perSystem =
        { config, pkgs, system, ... }:
        {

          devShells = {
            default = pkgs.callPackage ./shells/default/default.nix { inherit pkgs inputs; };
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
                  1. git clone http://10.0.0.65:3002/xiro/dotfiles.nix.git
                  2. cd dotfiles.nix
                  3. nix develop
                  4. just install HOSTNAME
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
