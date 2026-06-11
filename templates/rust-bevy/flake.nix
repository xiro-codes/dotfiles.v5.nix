{
  description = "A modern Bevy 0.17 project managed by Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts/71a3a77326609675e9f8b51084cf23d5d1945899";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay/366ea19e0e55b768f74b7a0b2a20f847e7ae828d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-nix = {
      url = "github:xiro-codes/nvim.nix";
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
          inherit (pkgsWithRust.lib) makeLibraryPath;

          nativeBuildInputs = with pkgsWithRust; [ pkg-config makeWrapper ];
          buildInputs = with pkgsWithRust; [
            udev
            alsa-lib
            vulkan-loader
            libxkbcommon
            wayland
            libx11
            libxcursor
            libxi
            libxrandr
          ];

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
            pname = "bevy-app";
            version = "0.1.0";
            src = ./.;
            cargoLock = {
              lockFile = ./Cargo.lock;
            };

            inherit nativeBuildInputs buildInputs;

            postInstall = ''
              wrapProgram $out/bin/bevy-app \
                --prefix LD_LIBRARY_PATH : "${makeLibraryPath buildInputs}"
            '';
          };

          devShells.default = pkgsWithRust.mkShell {
            nativeBuildInputs = nativeBuildInputs ++ [
              rustToolchain
              inputs.nvim-nix.packages.${system}.python-rust
            ];
            inherit buildInputs;
            LD_LIBRARY_PATH = makeLibraryPath buildInputs;

            shellHook = ''
              echo "🎮 Bevy Dev Environment Loaded"
              if [ ! -f Cargo.toml ]; then
                echo "=> No Cargo.toml found. Run 'cargo init' and 'cargo add bevy' to start."
              fi
              echo "Run 'direnv allow' to automatically load this environment."
            '';
          };
        };
    };
}
