{
  description = "A standard Rust CLI application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/15f4ee454b1dce334612fa6843b3e05cf546efab";
    flake-parts = {
      url = "github:hercules-ci/flake-parts/71a3a77326609675e9f8b51084cf23d5d1945899";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay/366ea19e0e55b768f74b7a0b2a20f847e7ae828d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-nix = {
      url = "path:/home/tod/Projects/nvim.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, rust-overlay, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, system, ... }:
        let
          overlays = [ (import rust-overlay) ];
          pkgsWithRust = import inputs.nixpkgs { inherit system overlays; };

          rustToolchain = pkgsWithRust.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
          };
        in
        {
          formatter = pkgs.nixfmt;
          packages.default = pkgsWithRust.rustPlatform.buildRustPackage {
            pname = "rust-cli";
            version = "0.1.0";
            src = ./.;
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
          };

          devShells.default = pkgsWithRust.mkShell {
            nativeBuildInputs = with pkgsWithRust; [
              rustToolchain
              pkg-config
              inputs.nvim-nix.packages.${system}.python-rust
            ];
            buildInputs = with pkgsWithRust; [ ];

            shellHook = ''
              echo "🦀 Rust CLI Dev Environment Loaded"
              echo "Rust version: $(rustc --version)"
              if [ ! -f Cargo.toml ]; then
                echo "=> No Cargo.toml found. Run 'cargo init' to set up a new project."
              fi
              echo "Run 'direnv allow' to automatically load this environment."
            '';
          };
        };
    };
}