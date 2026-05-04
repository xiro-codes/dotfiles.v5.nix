{
  description = "Rust ESP32-C3 Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

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
      }
    );
}
