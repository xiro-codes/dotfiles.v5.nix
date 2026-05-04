{
  description = "PlatformIO C/C++ Embedded Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            platformio
            python3
            python3Packages.pyserial
            clang-tools
            cppcheck
          ];

          shellHook = ''
            echo "🔧 PlatformIO Dev Environment"
            if [ ! -f platformio.ini ]; then
              echo "=> No platformio.ini found. Run 'pio project init -b <board_name>' to start."
            fi
            echo "Run 'pio run' to build, 'pio run -t upload' to flash."
            echo "Run 'direnv allow' to automatically load this environment."
          '';
        };
      }
    );
}
