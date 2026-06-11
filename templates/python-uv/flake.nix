{
  description = "Python development environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts/71a3a77326609675e9f8b51084cf23d5d1945899";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nvim-nix = {
      url = "github:xiro-codes/nvim.nix";
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
            name = "python-app";
            runtimeInputs = with pkgs; [ python313 ];
            text = ''
              python ${./app/main.py}
            '';
          };
          devShells.default =
            let
              inherit (pkgs.lib) makeLibraryPath;
            in
            pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              uv
              python313
              ruff
              basedpyright
              inputs.nvim-nix.packages.${system}.python
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

            LD_LIBRARY_PATH = makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];
          };
        };
    };
}
