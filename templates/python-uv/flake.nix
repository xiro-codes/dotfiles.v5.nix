{
  description = "Python development environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
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
        };
    };
}