{
  description = "Python and Rust development environment with uv and maturin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/15f4ee454b1dce334612fa6843b3e05cf546efab";
    flake-parts = {
      url = "github:hercules-ci/flake-parts/71a3a77326609675e9f8b51084cf23d5d1945899";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nvim-nix = {
      url = "path:/home/tod/Projects/nvim.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt;
          packages.default = pkgs.writeShellApplication {
            name = "python-rust-app";
            runtimeInputs = with pkgs; [
              python3
              uv
              maturin
              rustc
              cargo
              pkg-config
              openssl
              stdenv.cc
            ];
            text = ''
              if [ ! -d ".venv" ]; then
                # Use uv to create venv if available, otherwise python -m venv
                if command -v uv > /dev/null; then
                  uv venv
                else
                  python -m venv .venv
                fi
              fi
              # shellcheck disable=SC1091
              source .venv/bin/activate
              maturin develop
              python app/main.py
            '';
          };
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              # Python Tooling
              uv
              python313
              ruff
              basedpyright

              # Rust Tooling
              rustc
              cargo
              rust-analyzer
              rustfmt
              clippy
              maturin
              pkg-config
              openssl

              # Custom Editor
              inputs.nvim-nix.packages.${system}.python-rust
            ];

            shellHook = ''
              if [ ! -d ".venv" ]; then
                uv venv
              fi
              export VIRTUAL_ENV=$(pwd)/.venv
              export PATH="$VIRTUAL_ENV/bin:$PATH"
              export UV_PYTHON=$(which python3)

              source .venv/bin/activate

              echo "🐍🦀 Python-Rust Dev Shell Active (uv + maturin)"
              echo "Python: $(python --version) | Rust: $(rustc --version) | uv: $(uv --version)"
              if [ ! -f pyproject.toml ]; then
                echo "=> No pyproject.toml found. Run 'maturin init' to initialize the project."
              fi
              echo "Run 'direnv allow' to automatically load this environment."
            '';

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];
          };
        };
    };
}
