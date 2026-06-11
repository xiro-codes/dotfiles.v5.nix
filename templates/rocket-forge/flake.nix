{
  description = "Rocket Blog & Work Time Tracker";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-compose = {
      url = "github:garnix-io/nixos-compose";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      nixos-compose,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
          ];
        };

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          openssl
        ];

        app = rustPlatform.buildRustPackage {
          pname = "rocket-forge";
          version = "0.1.0";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.openssl ];
          doCheck = false;
          OPENSSL_NO_VENDOR = 1;

          postInstall = ''
            mkdir -p $out/share/rocket-blog
            cp -r templates $out/share/rocket-blog/
            cp -r static $out/share/rocket-blog/
          '';
        };

        app-debug = app.overrideAttrs (old: {
          buildType = "debug";
        });

      in
      {
        packages = {
          default = app;
          rocket-forge = app;
          rocket-forge-debug = app-debug;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = nativeBuildInputs ++ [ rustToolchain ];
          inherit buildInputs;
          packages = with pkgs; [
            sea-orm-cli
            cargo-watch
            just
            nixos-compose.packages.${system}.default
          ];
          shellHook = ''
            echo "🦀 Rust Dev Environment Loaded"
            echo "Rust version: $(rustc --version)"
          '';
        };
      }
    )
    // {
      nixosModules.default = import ./nix/module.nix { inherit self; };

      nixosConfigurations.rocket-forge-container = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { config, pkgs, ... }:
            {
              boot.isContainer = true;
              boot.isNspawnContainer = true;
              imports = [ self.nixosModules.default ];
              system.stateVersion = "23.11";
              services.rocket-forge = {
                enable = true;
                manageDatabase = true;
                secretKeyFile = ./.rocket_secret_key;
              };
              networking.nameservers = [ "192.168.1.65" ];
              networking.firewall.allowedTCPPorts = [ 80 ];
            }
          )
        ];
      };

      nixosConfigurations.test-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { config, pkgs, ... }:
            {
              imports = [ self.nixosModules.default ];
              system.stateVersion = "24.11";

              # Minimal configuration for the VM
              users.users.testuser = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                password = "test";
              };

              # Allow password auth for testing if needed
              services.openssh.enable = true;
              services.openssh.settings.PasswordAuthentication = true;

              fileSystems."/" = {
                device = "/dev/vda1";
                fsType = "ext4";
              };
              boot.loader.grub.device = "/dev/vda";

              services.rocket-forge = {
                enable = true;
                manageDatabase = true;
                secretKeyFile = ./.r;
              };

              networking.firewall.allowedTCPPorts = [
                80
                8000
                22
              ];
            }
          )
        ];
      };
    };
}
