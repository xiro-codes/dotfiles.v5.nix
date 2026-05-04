{
  description = "Rust ESP32-C3 Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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
          pkgs = import inputs.nixpkgs { inherit system overlays; };

          rustTarget = "riscv32imc-unknown-none-elf";
          rustToolchain = pkgs.rust-bin.nightly.latest.default.override {
            targets = [ rustTarget ];
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
          };
        in
        {
          formatter = pkgs.nixfmt;
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustToolchain
              espflash
              pkg-config
              openssl
              libiconv
            ];

            shellHook = ''
              echo "🦀 ESP32-C3 Rust Dev Environment"
              echo "Target: ${rustTarget}"
              if [ ! -f Cargo.toml ]; then
                echo "=> No Cargo.toml found. Run 'cargo generate esp-rs/esp-template' to bootstrap a new project."
              fi
              echo "Run 'cargo build' to compile or 'espflash flash' to deploy."
              echo "Run 'direnv allow' to automatically load this environment."
            '';
          };
        };
    };
}