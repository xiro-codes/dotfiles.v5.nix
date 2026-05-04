{
  description = "Python development environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            uv
            python313
            ruff
            basedpyright
          ];

          shellHook = ''
            if [ ! -d ".venv" ]; then
              uv venv
            fi
            export VIRTUAL_ENV=$(pwd)/.venv
            export PATH="$VIRTUAL_ENV/bin:$PATH"
            export UV_PYTHON=$(which python3)

            source .venv/bin/activate

            echo "🐍 Python Dev Shell Active (uv)"
            echo "Python: $(python --version) | uv: $(uv --version)"
            if [ ! -f pyproject.toml ]; then
              echo "=> No pyproject.toml found. Run 'uv init' to initialize the project."
            fi
            echo "Run 'direnv allow' to automatically load this environment."
          '';

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];
        };
      });
}
